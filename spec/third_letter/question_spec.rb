require "spec_helper"
require 'byebug'

# Question — вопрос, на который отвечают эксперты.
#
# `#answer` возвращает наиболее полезный ответ, опираясь на максимальный score
# `#address_to` пересылает вопрос эксперту почтой.
class Question
  attr_reader :summary, :responses

  def initialize(summary:, responses: [])
    @summary = summary
    @responses = responses
  end

  def answer
    responses.max_by(&:score)
  end

  def address_to(expert)
    QuestionMail.new(self, recipient: expert).deliver
  end
end

class Response
  attr_reader :text, :author

  def initialize(text:, author:)
    @text = text
    @author = author
  end

  def score
    ResponseText.new(text).score
  end
end

class ResponseText
  def initialize(response)
    @response = response
  end

  def score
    # Возвращаем число, полезность ответа. Учитываем:
    #   — наличие опечаток через HTTP API;
    #   — наличие картинок в тексте;
    #   — количество и качество текста (через API Главреда).
  end
end

class QuestionMail
  def initialize(question, recipient:)
    @question = question
    @recipient = recipient
  end

  def deliver
    # Собираем и отправляем письмо с вопросом получателю (`recipient`)
  end
end
RSpec.describe Question do
  describe '#initialize' do

    let(:summary) { 'test summary' }
    let(:responses) { [Response.new(text: 'test', author: 'author')] }
    let(:double_question_mail) { instance_double(QuestionMail) }
    let(:question) { Question.new(summary: summary, responses: responses) }
    let(:double_response_text) { instance_double(ResponseText) }
    let(:expert) { 'expert' }
    let(:recipient) { expert }

    before do
      allow(ResponseText).to receive(:new).with(text: 'test').and_return(double_response_text)
      allow(double_response_text).to receive(:score).and_return(3)
      allow(QuestionMail).to receive(:new).with(question, recipient: recipient).and_return(double_question_mail)
      allow(double_question_mail).to receive(:deliver).and_return(true)
    end

    context 'when success' do

    it { expect(double_response_text.score).to eq(3) }
    it { expect(double_question_mail.deliver).to eq(true) }
    end
  end
end
