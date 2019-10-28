# frozen_string_literal: true

module JsChartHelper
  def generate_colors number, saturation: 1, lightness: 0.7
    Array.new(number) {|i| hsv_to_rgb_hex (i.to_f / number), saturation, lightness }
  end

  def hsv_to_rgb hue_percentage, saturation, lightness
    m2 = if lightness <= 0.5
      lightness * (saturation + 1)
    else
      lightness + saturation - lightness * saturation
    end

    m1 = lightness * 2 - m2

    [
      hue_to_rgb(m1, m2, hue_percentage + 1.0 / 3),
      hue_to_rgb(m1, m2, hue_percentage),
      hue_to_rgb(m1, m2, hue_percentage - 1.0 / 3),
    ].map { |c| (c * 0xff).round }
  end

  def hsv_to_rgb_hex hue, saturation, lightness
    '#' + hsv_to_rgb(hue, saturation, lightness).map {|c| format('%<rgb>02X', rgb: c) }.join
  end

  # helper for making rgb
  def hue_to_rgb(m1, m2, h)
    h += 1 if h.negative?
    h -= 1 if h > 1
    return m1 + (m2 - m1) * h * 6 if h * 6 < 1
    return m2 if h * 2 < 1
    return m1 + (m2 - m1) * (2.0 / 3 - h) * 6 if h * 3 < 2

    m1
  end

  def transform_to_chart_data data
    labels = []
    raw_data = []
    colors = generate_colors data.length
    data.each do |c|
      labels << c[:name]
      raw_data << c[:data]
    end
    {
      labels: labels,
      datasets: [
        {data: raw_data, backgroundColor: colors, hoverBackgroundColor: colors},
      ],
    }
  end
end
