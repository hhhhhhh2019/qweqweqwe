{ pkgs }: {
	test = stdlib.mkDerivation {
		name = "test";
		version = "0.0.1";

		src = stdlib.fetchurl {
			url = "github:hhhhhhh2019/test";
			sha256 = "qweqweqweqweqweqweqwe";
		};

		dependencies = with pkgs; [ gnumake, libtest ];

		buildInput = with pkgs; [ gcc ];
		build = ''
			make
			make install prefix=${output}
		'';

		install = ''
			ln -sf ${output}/bin/test /bin/test
		'';
		
		files = config: {
			'${output}/etc/test.conf' = ''
				name = ${config.name}
				${config.config or ""}
			'';
		}
	};

	gcc = stdlib.mkDerivation {
		name = "test";
		version = "0.0.1";

		src = stdlib.fetchurl {
			url = "github:hhhhhhh2019/gcc";
			sha256 = "ewqewqewqewqewqewqewq";
		};

		buildInput = with pkgs; [ gnumake ];
		build = ''
			./configure prefix=${output}
			make
			make install
		'';

		install = ''
			ln -sf ${output}/bin/* /bin/gcc
		'';
	};

	gcc = stdlib.mkDerivation {
		name = "gnumake";
		version = "0.0.1";

		src = stdlib.fetchurl {
			url = "github:hhhhhhh2019/gnumake";
			sha256 = "weqweqweqweqweqweqweqweq";
		};

		buildInput = with pkgs; [ ];
		build = ''
			./build.sh
			./install.sh prefix=${output}
		'';

		install = ''
			ln -sf ${output}/bin/make /bin/make
		'';
	};

	libtest = stdlib.mkDerivation {
		name = "libtest";
		version = "0.0.1";

		src = stdlib.fetchurl {
			url = "github:hhhhhhh2019/libtest";
			sha256 = "weqweqweqweqweqweqweqweq";
		};

		buildInput = with pkgs; [ gnumake ];
		build = ''
			make
			make install prefix=${output}
		'';

		install = ''
			export LIBRARY_PATH=$LIBRARY_PATH:${output}/lib
			export CPATH=CPATH:/${output}/include
		'';
	};
}
