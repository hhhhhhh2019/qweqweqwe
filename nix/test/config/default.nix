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

		packages = with os; [
			test_pkg,
		];
	}
}
