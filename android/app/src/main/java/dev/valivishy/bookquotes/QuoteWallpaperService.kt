package dev.valivishy.bookquotes

import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
import android.os.Handler
import android.os.Looper
import android.service.wallpaper.WallpaperService
import android.text.Layout
import android.text.StaticLayout
import android.text.TextPaint
import android.view.SurfaceHolder
import org.json.JSONArray
import java.net.URL
import kotlin.concurrent.thread

class QuoteWallpaperService : WallpaperService() {

    override fun onCreateEngine(): Engine = QuoteEngine()

    inner class QuoteEngine : Engine() {

        private val handler = Handler(Looper.getMainLooper())
        private val rotateMs = 30 * 60 * 1000L
        private var quotes = emptyList<Quote>()
        private var currentIndex = -1

        private val bgPaint = Paint().apply { color = Color.parseColor("#111111") }

        private val quotePaint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.parseColor("#E6FFFFFF")
            typeface = Typeface.create("serif", Typeface.ITALIC)
            textSize = 56f
        }

        private val authorPaint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.parseColor("#CCFFFFFF")
            typeface = Typeface.create("serif", Typeface.BOLD)
            textSize = 36f
        }

        private val rotateRunnable = Runnable { nextQuote() }

        override fun onSurfaceCreated(holder: SurfaceHolder) {
            super.onSurfaceCreated(holder)
            loadQuotes()
        }

        override fun onVisibilityChanged(visible: Boolean) {
            if (visible) {
                draw()
                scheduleRotation()
            } else {
                handler.removeCallbacks(rotateRunnable)
            }
        }

        override fun onSurfaceDestroyed(holder: SurfaceHolder) {
            handler.removeCallbacks(rotateRunnable)
            super.onSurfaceDestroyed(holder)
        }

        private fun loadQuotes() {
            // Try cached first
            val prefs = applicationContext.getSharedPreferences("bq", MODE_PRIVATE)
            val cached = prefs.getString("quotes_json", null)
            if (cached != null) {
                quotes = parseQuotes(cached)
                nextQuote()
            }

            // Fetch fresh in background
            thread {
                try {
                    val json = URL(QUOTES_URL).readText()
                    val parsed = parseQuotes(json)
                    if (parsed.isNotEmpty()) {
                        prefs.edit().putString("quotes_json", json).apply()
                        quotes = parsed
                        if (currentIndex < 0) handler.post { nextQuote() }
                    }
                } catch (_: Exception) {
                    if (quotes.isEmpty()) handler.post { draw() }
                }
            }
        }

        private fun parseQuotes(json: String): List<Quote> {
            val arr = JSONArray(json)
            return (0 until arr.length()).map { i ->
                val obj = arr.getJSONObject(i)
                Quote(
                    text = obj.getString("text"),
                    author = obj.optString("author", "")
                )
            }
        }

        private fun nextQuote() {
            if (quotes.isEmpty()) return
            currentIndex = (0 until quotes.size).random()
            draw()
            scheduleRotation()
        }

        private fun scheduleRotation() {
            handler.removeCallbacks(rotateRunnable)
            handler.postDelayed(rotateRunnable, rotateMs)
        }

        private fun draw() {
            val holder = surfaceHolder
            var canvas: Canvas? = null
            try {
                canvas = holder.lockCanvas() ?: return
                drawQuote(canvas)
            } finally {
                if (canvas != null) {
                    try { holder.unlockCanvasAndPost(canvas) } catch (_: Exception) {}
                }
            }
        }

        private fun drawQuote(canvas: Canvas) {
            val w = canvas.width.toFloat()
            val h = canvas.height.toFloat()

            canvas.drawRect(0f, 0f, w, h, bgPaint)

            if (quotes.isEmpty() || currentIndex < 0) return

            val quote = quotes[currentIndex]
            val padding = w * 0.1f
            val textWidth = (w - padding * 2).toInt()

            // Scale font sizes based on screen width
            val scale = w / 1080f
            quotePaint.textSize = 52f * scale
            authorPaint.textSize = 34f * scale

            // Build text layouts
            val quoteLayout = StaticLayout.Builder
                .obtain(quote.text, 0, quote.text.length, quotePaint, textWidth)
                .setAlignment(Layout.Alignment.ALIGN_CENTER)
                .setLineSpacing(12f * scale, 1f)
                .build()

            val attribution = buildAttribution(quote)
            val authorLayout = if (attribution.isNotEmpty()) {
                StaticLayout.Builder
                    .obtain(attribution, 0, attribution.length, authorPaint, textWidth)
                    .setAlignment(Layout.Alignment.ALIGN_CENTER)
                    .build()
            } else null

            val gap = 24f * scale
            val totalHeight = quoteLayout.height + gap +
                (authorLayout?.height?.toFloat() ?: 0f)

            var y = (h - totalHeight) / 2f

            // Quote text
            canvas.save()
            canvas.translate(padding, y)
            quoteLayout.draw(canvas)
            canvas.restore()
            y += quoteLayout.height + gap

            // Author
            if (authorLayout != null) {
                canvas.save()
                canvas.translate(padding, y)
                authorLayout.draw(canvas)
                canvas.restore()
            }
        }

        private fun buildAttribution(quote: Quote): String =
            if (quote.author.isNotEmpty()) "\u2014 ${quote.author}" else ""

    }

    data class Quote(val text: String, val author: String)

    companion object {
        private const val QUOTES_URL =
            "https://raw.githubusercontent.com/valivishy/automatic-invention-quotes/master/book-quotes.widget/quotes.json"
    }
}
