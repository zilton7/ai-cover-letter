class CoverLettersController < ApplicationController
  def show
    @cover_letter = CoverLetter.find(params[:id]) # TODO: protect for current_user access only
    render partial: 'cover_letters/cover_letter', locals: { cover_letter: @cover_letter.body }
  end
end
