require 'rails_helper'

describe Admin::PublicAnnouncement do

  it "should create temp load announcement and long-term announcement" do
    pa_text='This is a loading announcement'
    pa_lt_text='This is a long term announcement'

    Admin::PublicAnnouncement.populate(pa_text)
    Admin::PublicAnnouncement.populate_long_term(pa_lt_text)
    expect(Admin::PublicAnnouncement.count).to eq(2)
    pa=Admin::PublicAnnouncement.where('description=?',pa_text)
    lt_pa=Admin::PublicAnnouncement.where('description=?',pa_lt_text)
    expect(pa.size).to eq(1)
    expect(lt_pa.size).to eq(1)
    expect(pa.first.is_sticky).to eq(nil)
    expect(lt_pa.first.is_sticky).to eq(true)

    Admin::PublicAnnouncement.clear_load_message
    # Should not remove long term message
    pa=Admin::PublicAnnouncement.where('description=?',pa_text)
    expect(pa.size).to eq(0)
    expect(Admin::PublicAnnouncement.count).to eq(1)
    expect(Admin::PublicAnnouncement.first.is_sticky).to eq(true)
    expect(Admin::PublicAnnouncement.first.description).to eq(pa_lt_text)
  end

end
