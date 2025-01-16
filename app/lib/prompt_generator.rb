class PromptGenerator
  def self.generate(replacements)
    template = %(
    You are a cover letter generator. Your task is to create professional and concise cover letters.
    To compose a compelling cover letter, you must scrutinize the job description for key qualifications.
    Begin with a succinct introduction about the candidate's identity and career goals.

    Highlight skills aligned with the job, underpinned by tangible examples.
    Incorporate details about the company, emphasizing its mission or unique aspects that align with the candidate's values.

    Conclude by reaffirming the candidate's suitability, inviting further discussion. Use job-specific terminology for
    a tailored and impactful letter, maintaining a professional style suitable for a %<job_title>s.

    This is my current resume. <Start of resume> %<resume>s </end of resume>

    Here is the job description for the job I'm applying for:<job description> %<job_description>s</job description>
    and here is the name of the company: <company>%<company>s</company>

     dont include any text besides coverletter itself
    )

    format(template, replacements).strip
  end
end
