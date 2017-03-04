require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#hsv_to_rgb' do
    it('red')   { expect(helper.hsv_to_rgb(0, 1, 0.5)).to       eq [255, 0, 0] }
    it('green') { expect(helper.hsv_to_rgb(1.0/3, 1, 0.5)).to   eq [0, 255, 0] }
    it('blue')  { expect(helper.hsv_to_rgb(2.0/3, 1, 0.5)).to   eq [0, 0, 255] }
    it('olive') { expect(helper.hsv_to_rgb(1.0/6, 1, 0.25)).to  eq [127, 128, 0] }
    it('gray')  { expect(helper.hsv_to_rgb(0, 0, 0.5)).to       eq [128, 128, 128] }
    it('silver'){ expect(helper.hsv_to_rgb(0, 0, 0.75)).to      eq [191, 191, 191] }
  end

  describe '#hsv_to_rgb_hex' do
    it('red')   { expect(helper.hsv_to_rgb_hex(0, 1, 0.5)).to       eq '#FF0000' }
    it('green') { expect(helper.hsv_to_rgb_hex(1.0/3, 1, 0.5)).to   eq '#00FF00' }
    it('blue')  { expect(helper.hsv_to_rgb_hex(2.0/3, 1, 0.5)).to   eq '#0000FF' }
    it('olive') { expect(helper.hsv_to_rgb_hex(1.0/6, 1, 0.25)).to  eq '#7F8000' }
    it('gray')  { expect(helper.hsv_to_rgb_hex(0, 0, 0.5)).to       eq '#808080' }
    it('silver'){ expect(helper.hsv_to_rgb_hex(0, 0, 0.75)).to      eq '#BFBFBF' }
  end

  describe '#generate_colors' do
    it('1 colors') { expect(helper.generate_colors 1).to eq ['#FF6666'] }
    it('3 colors') { expect(helper.generate_colors 3).to eq ['#FF6666', '#66FF66', '#6666FF'] }
    it('10 colors') { expect(helper.generate_colors 10).to eq ['#FF6666', '#FFC266', '#E0FF66', '#85FF66', '#66FFA3', '#66FFFF', '#66A3FF', '#8566FF', '#E066FF', '#FF66C2'] }
    it('3 light colors') { expect(helper.generate_colors 3, lightness: 0.80).to eq ['#FF9999', '#99FF99', '#9999FF'] }
    it('3 dark colors') { expect(helper.generate_colors 3, lightness: 0.25).to eq ['#800000', '#008000', '#000080'] }
    it('3 colors with low saturation') { expect(helper.generate_colors 3, saturation: 0.5).to eq ['#D98C8C', '#8CD98C', '#8C8CD9'] }
  end
end
