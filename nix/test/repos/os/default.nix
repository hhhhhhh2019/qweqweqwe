{
	system ? builtins.currentSystem,
}: rec {
	pkgs = import './pkgs' self.pkgs;
	generate = { config }: let
		pkgs = self.pkgs;
	in [
		if config.test.enable then pkgs.test + pkgs.test config.test else nil,
	] + config.packages;
}
