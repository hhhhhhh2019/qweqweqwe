# Идея
nex(пока буду называть его так) - это декларативный пакетный менеджер с излированными, неизменяемыми пакетами.

репозиторий - это именованное множество и функция, которая принимает на вход системную конфигурацию, а возвращает список дериваций пакетов.

В деривацию пакета входит:
  - откуда скачать исходники
	- что нужно для сборки
  - как собрать пакет
  - дополнительные файлы(например конфигурация vim)


Например из конфигурации

```
{ pkgs }: {
	services.printing.enable = true;
	
	programs.vim = {
		enable = true;
		plugins = with pkgs.vim; [
			fugitive,
			surround,
		];
		colorscheme = pkgs.vim.catppccin.latte;
	};
}
```

получится, что-то типа (config - путь до папки config внутри папки деривации пакета в nex store):

```
[
	{
		name = "cups";
		version = "1.2.3";
		src = stdlib.fetchurl "url to cups source code";
		buildInputs = [ 'path to dbus in nex store', 'path to gcc in nex store', 'path to glibc in nex store', ... ];
		build = ''
			./configure
			make
		'';
		install
	},
	{
		name = "vim";
		version = "9.1.740";
		src = stdlib.fetchurl "url to vim source code";
		buildInputs = [ 'path to ncurses', 'gcc', 'glibc', ... ];
		build = ''
			./configure
			make
		'';
		files = {
			'${config}/plugins/fugitive/' = stdlib.fetchurl "github:i am too lazy for search/fugitive.vim";
			...
			'${config}/init.vim' = ''
				" i hope plugins can be loaded this way
				set runtimepath^=${config}/plugins/fugitive/some file.vim
				...
				set termguicolors
				set colorscheme=catppuccin_latte
			'';
			'${cofnig}/colors/catppuccin_latte.vim' = ''
				see https://github.com/catppuccin/vim/blob/main/colors/catppuccin_latte.vim
			'';
		};
	},
	{
		name = "libncurses";
		version = "idk";
		src = stdlib.fetchurl "url to ncurses source code";
		buildInputs = [...];
		...
	},
	...
]
```
