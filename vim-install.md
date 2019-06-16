./configure --with-features=huge --enable-rubyinterp --enable-pythoninterp --with-python-config-dir=/usr/lib64/python3.4/config-3.4m/ --enable-perlinterp --enable-gui=gtk2 --enable-cscope --enable-luainterp --enable-perlinterp --enable-multibyte --prefix=/usr/

make

make install



其中参数说明如下： 

–with-features=huge：支持最大特性
 
–enable-rubyinterp：启用Vim对ruby编写的插件的支持 

–enable-pythoninterp：启用Vim对python编写的插件的支持 

–enable-luainterp：启用Vim对lua编写的插件的支持 

–enable-perlinterp：启用Vim对perl编写的插件的支持 

–enable-multibyte：多字节支持 可以在Vim中输入中文 

–enable-cscope：Vim对cscope支持 

–enable-gui=gtk2：gtk2支持,也可以使用gnome，表示生成gvim 

–with-python-config-dir=/usr/lib/python2.7/config-i386-linux-gnu/ 指定 python 路径 

–prefix=/usr：编译安装路径 

第二步如果报You need to install a terminal library; for example ncurses. Or specify the name of the library with --with-tlib.

sudo yum  install  ncurses-devel
