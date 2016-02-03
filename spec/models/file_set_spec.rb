require 'rails_helper'

describe FileSet do
  it 'is open visibility by default.' do
    expect(subject.visibility).to eq 'open'
  end

  describe "derivative generation" do
    let(:outputs) do
      [{ label: :thumbnail, format: 'jpg',
                  size: '150x150',
                  url: 'dummy_url' }]
    end
    let(:f_name) {'dummy_filename'}
    let(:fake_class) do
      Class.new { def create(*args); end; }
    end

    before do
      allow(subject).to receive(:derivative_url).and_return("dummy_url")
    end

    it 'generates only thumbnails from pdfs.' do
      allow(subject).to receive(:mime_type).and_return('application/pdf')
      expect(Hydra::Derivatives::FullTextExtract).to_not receive(:create)
      expect(Hydra::Derivatives::PdfDerivatives).to receive(:create).with(f_name, outputs: outputs)
      subject.create_derivatives(f_name)
    end

    it 'generates only thumbnails from document types.' do
      allow(subject).to receive(:mime_type).and_return('text/rtf')
      expect(Hydra::Derivatives::FullTextExtract).to_not receive(:create)
      expect(Hydra::Derivatives::DocumentDerivatives).to receive(:create).with(f_name, outputs: outputs)
      subject.create_derivatives('dummy_filename')
    end

    it 'only generates thumbnail from video.' do
      allow(subject).to receive(:mime_type).and_return('video/mp4')
      expect(Hydra::Derivatives::VideoDerivatives).to receive(:create).with(f_name, outputs: outputs)
      subject.create_derivatives('dummy_filename')
    end

    it 'does not generate audio derivatives.' do
      allow(subject).to receive(:mime_type).and_return('audio/mp3')
      expect(Hydra::Derivatives::AudioDerivatives).to_not receive(:create)
      subject.create_derivatives('dummy_filename')
    end
  end
end
