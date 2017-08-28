require 'rails_helper'

describe PublicAnnouncement do

  it "should create temp load announcement and long-term announcement" do
    pa_text='This is a loading announcement'
    pa_lt_text='This is a long term announcement'

    PublicAnnouncement.populate(pa_text)
    PublicAnnouncement.populate_long_term(pa_lt_text)
    expect(PublicAnnouncement.count).to eq(2)
    pa=PublicAnnouncement.where('description=?',pa_text)
    lt_pa=PublicAnnouncement.where('description=?',pa_lt_text)
    expect(pa.size).to eq(1)
    expect(lt_pa.size).to eq(1)
    expect(pa.first.is_sticky).to eq(nil)
    expect(lt_pa.first.is_sticky).to eq(true)

    PublicAnnouncement.clear_load_message
    # Should not remove long term message
    pa=PublicAnnouncement.where('description=?',pa_text)
    expect(pa.size).to eq(0)
    expect(PublicAnnouncement.count).to eq(1)
    expect(PublicAnnouncement.first.is_sticky).to eq(true)
    expect(PublicAnnouncement.first.description).to eq(pa_lt_text)
  end

end
