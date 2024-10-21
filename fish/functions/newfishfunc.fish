function newfishfunc
    read -P "Enter the name for the new Fish function: " func_name

    set func_path ~/.config/fish/functions/$func_name.fish

    if test -e $func_path
        echo "A function named '$func_name' already exists."
        read -P "Do you want to edit it? [y/N] " response
        if test "$response" != "y" -a "$response" != "Y"
            return 1
        end
    else
        echo "function $func_name
    # Function code here
end" > $func_path
        echo "Created new function file: $func_path"
    end

    $EDITOR $func_path
end
