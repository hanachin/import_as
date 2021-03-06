using ImportAs

import { C as D }.from File.expand_path("./c.rb", __dir__)

RSpec.describe ImportAs do
  it 'rename C as D' do
    expect { C }.to raise_error(NameError, /uninitialized constant C/)
    expect { D.new.hi }.to output(/\Ahi\n\z/).to_stdout
  end
end
