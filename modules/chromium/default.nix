{ ... }:

{
	config.programs.chromium = {
		enable = true;
		extensions = [
			"gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
			"cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
			"iipjdmnoigaobkamfhnojmglcdbnfaaf" # Clutter Free
			"bdakmnplckeopfghnlpocafcepegjeap" # RescueTime
			"gppongmhjkpfnbhagpmjfkannfbllamg" # wappalyzer
			"lcbjdhceifofjlpecfpeimnnphbcjgnc" # xBrowserSync
			"chlffgpmiacpedhhbkiomidkjlcfhogd" # pushbullet
			"aghfnjkcakhmadgdomlmlhhaocbkloab" # just black
			"fmkadmapgofadopljbjfkapdkoienihi" # React Developer Tools
		];
		homepageLocation = "https://sx.illustris.tech/";
		defaultSearchProviderSuggestURL = "https://sx.illustris.tech/autocompleter?q={searchTerms}";
		defaultSearchProviderSearchURL = "https://sx.illustris.tech/search?q={searchTerms}";
		extraOpts = {
			DefaultSearchProviderEnabled = true;
			DefaultSearchProviderName = "Sx";
			DefaultCookiesSetting = 1;
		};
	};
}