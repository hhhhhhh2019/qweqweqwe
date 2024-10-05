{
	lib,
}: let
	version = "0.0.1";
in lib.mkDerivation {
	description = "qweqweqweqw";
	inherit version;

	src = lib.fetchtarball {
		url = "https://qweqweqwe.com/pkgs/test-${version}.tar.gz";
		sha256 = "62090f2241986a8361242e47cf541657099fdccc0c08e34cd694922bdcf31893";
	};

	buildDependencies = [
		pkgs.libncurses,
	];

	build = ''
		make
	'';

	dependencies = [
		pkgs.libncurses,
	];
}
