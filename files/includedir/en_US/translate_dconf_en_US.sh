#~/bin/bash
    # Change the name of menus in Gnome
    echo "Change the name of menus in Gnome"
    sed -i "s/name='Setări teme'/name='Themes settings'/g" ../etc/dconf/db/local.d/27-app-folders
    sed -i "s/name='Birou'/name='Office'/g" ../etc/dconf/db/local.d/27-app-folders
    sed -i "s/name='Grafică'/name='Graphics'/g" ../etc/dconf/db/local.d/27-app-folders
    sed -i "s/name='Programare'/name='Programming'/g" ../etc/dconf/db/local.d/27-app-folders
    sed -i "s/name='Accesorii'/name='Accessories'/g" ../etc/dconf/db/local.d/27-app-folders
    sed -i "s/'name': 'Programare'/'name': 'Programming'/g" ../etc/dconf/db/local.d/12-extensions-arcmenu
    sed -i "s/'name': 'Sistem'/'name': 'System'/g" ../etc/dconf/db/local.d/12-extensions-arcmenu
    sed -i "s/'name': 'Birou'/'name': 'Office'/g" ../etc/dconf/db/local.d/12-extensions-arcmenu
    sed -i "s/'name': 'Grafică'/'name': 'Graphics'/g" ../etc/dconf/db/local.d/12-extensions-arcmenu
    sed -i "s/'name': 'Accesorii'/'name': 'Accessories'/g" ../etc/dconf/db/local.d/12-extensions-arcmenu
    sed -i "s/'name': 'Setări teme'/'name': 'Themes settings'/g" ../etc/dconf/db/local.d/12-extensions-arcmenu
    # Change the default keyboard in Gnome from 'ro' to 'us'
    echo "Change the default keyboard in Gnome from 'ro' to 'us'"
    sed -i "s/sources=\[('xkb', 'ro'), ('xkb', 'us')]\s*/sources=[('xkb', 'us')]/g"  ../etc/dconf/db/local.d/01-input-sources
    sed -i "s/mru-sources=\[('xkb', 'ro'), ('xkb', 'us')]\s*/mru-sources=[('xkb', 'us')]/g"  ../etc/dconf/db/local.d/01-input-sources
