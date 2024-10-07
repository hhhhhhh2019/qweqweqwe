{
	inputs = {
		os = {
			url = "file:~/progs/newpkg/nix/test/repos/os";
		};
	};

	output = { os }: let
		system = "x86_64-linux";
	in {
		test.enable = true;
		a = x: x + 2;

		packages = with os.pkgs; [
			gcc,
		];
	};
}
