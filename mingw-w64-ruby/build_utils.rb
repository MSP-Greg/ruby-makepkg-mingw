# cd D:\mingw-ri\mingw-w64-ruby
# ruby build_utils.rb

module BuildUtils

  @git_dir = nil

  def set_git_dir=(git_dir)
    @git_dir = git_dir if Dir.exist?(git_dir)
  end

  def pull_trunk
    return unless @git_dir
    Dir.chdir(@git_dir) { |d|
      `git pull ruby trunk`
      svn = (`git log -1`)[/svn\+ssh[^\s]+?@(\d+)/, 1]
      File.open('revision.h', 'wb:utf-8') { |f|
        f.write "#define RUBY_REVISION #{svn}\n"
      }
    }
  end
  
  def clean_repo
    return unless @git_dir
    Dir.chdir(@git_dir) { |dir|
      `del configure`
      `del tool\\configure.guess`
      `del tool\\configure.sub`
      `rd /s /q autom4te.cache`
      `rd /s /q enc\\unicode\\data`
    }
    `rd /s /q src\\build-x86_64-w64-mingw32`
    `rd /s /q pkg\\mingw-w64-x86_64-ruby`
  end
end

module Test_BU
  extend BuildUtils
end

Test_BU.set_git_dir = 'D:\/GitHub\/ruby'
Test_BU.pull_trunk
Test_BU.clean_repo
