function fish_prompt
    set_color blue
    echo -n (prompt_pwd)
    
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set_color normal
        echo -n ' '
        set_color cyan
        echo -n (basename (git rev-parse --show-toplevel))
        set_color normal
        echo -n ' '
        set_color yellow
        echo -n (git branch --show-current)
        
        set -l git_status (git status --porcelain)
        if test -n "$git_status"
            set_color FF69B4  # Light pink
            echo -n '*'
            # Removed the counting of modified, added, and deleted files
        end
    end
    
    echo

    set -l lang (detect_language)
    set_color $lang
    echo -n '❯ '
    set_color normal
end

function detect_language
    if test -f package.json
        echo yellow  # JavaScript/Node.js
    else if test -f Cargo.toml
        echo FF4500  # Rust (dark orange)
    else if test -f requirements.txt; or test -f pyproject.toml
        echo 3776AB  # Python (official color)
    else if test -f Gemfile
        echo CC342D  # Ruby (official color)
    else if test -f go.mod
        echo 00ADD8  # Go
    else if test -f pom.xml; or test -f build.gradle
        echo red  # Java
    else if test -f composer.json
        echo 777BB4  # PHP
    else if test -f CMakeLists.txt
        echo 00599C  # C++
    else
        echo c678dd  # Default (as requested)
    end
end
