function up
    if test (count $argv) -eq 0
        cd ..
    else
        set depth $argv[1]
        set path ..
        for i in (seq 2 $depth)
            set path "$path/.."
        end
        cd $path
    end
end
