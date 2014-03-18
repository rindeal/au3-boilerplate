#include-once
;~ #AutoIt3Wrapper_au3check_parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w- 7

; #FUNCTION# ====================================================================================================================
; Name ..........: _FileGetMime
; Description ...: Retrieves a mime type for the specified file.
; Syntax ........: _FileGetMime($sFileName[, $iOptions = 0[, $sDefaultMime = "application/octet-stream"]])
; Parameters ....: $sFileName           - A string value. A filename/path/URL (must contain a dot - extension)
;                  $iOptions            - [optional] An integer value. Default is 0. Options driving the behaviour of the resolving of the MIME.
;                                                Any combination of the following values:
;                                                0 - IANA strict DB
;                                                1 - IANA non-strict DB
;                                                2 - Windows Registery
;                                                4 - Guess from the file type in the Windows Registery
;                                                8 - Guess just from the extension
;                  $sDefaultMime    - [optional] A string value. Default is "application/octet-stream".
;                                                    A Default MIME that will be returned if none was found.
; Return values .: Success - A valid mime type. (valid as much as your options allowed)
;                  Failure - The default mime type and if the filename has had no extension then sets @error to non-zero
; Author ........: rindeal
; Modified ......:
; Remarks .......: RegEx DB search provided by trancexx's __WinHttpMime
; Related .......: __WinHttpMime
; Link ..........:
; Example .......: yes
; ===============================================================================================================================
Func _FileGetMime($sFileName, $iOptions = 0, $sDefaultMime = "application/octet-stream")
	; in the worst case it takes about 0.12 - 0.14 ms to proceed
	If Not StringInStr($sFileName, ".", 2) Then Return SetError(1, 0, $sDefaultMime)
	Local $sExtension, $aArray, $sMime, $sFileType
	$sExtension = StringRegExp($sFileName, "(?i)\.([^\\/.?=@]+)[^.]*$", 3)[0]
	$aArray = StringRegExp(__FileGetMime_GetDB(BitAND(1, $iOptions)), "(?i)\Q|" & $sExtension & "\E;(.*?)\|", 3)
	If Not @error Then Return $aArray[0]
	If BitAND(2, $iOptions) Then
		$sMime = RegRead('HKCR\.' & $sExtension, 'Content Type')
		If Not @error Then Return $sMime
	EndIf
	If BitAND(4, $iOptions) Then
		$sFileType = RegRead('HKCR\.' & $sExtension, 'PerceivedType')
		If Not @error Then Return $sFileType & '/x-' & $sExtension
	EndIf
	If BitAND(8, $iOptions) Then
		Return "application/x-" & $sExtension
	EndIf
	Return $sDefaultMime
EndFunc   ;==>_FileGetMime

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __FileGetMime_GetDB
; Description ...: Reurns a string that will be passed to a DB search function
; Syntax ........: __FileGetMime_GetDB([$iIANA_NonStrict = False])
; Parameters ....: $iIANA_NonStrict     - [optional] An integer value. Default is False.
;                                           Set to true if IANA non-strict MIMEs should be returned as well
; Return values .: A string that will be passed to a DB search function
; Author ........: rindeal
; Modified ......: guiness
; Remarks .......: Initial idea and IANA strict DB from trancexx's __WinHttpMIMEAssocString()
; Related .......: __WinHttpMIMEAssocString()
; Link ..........: http://www.stdicon.com/Mimes
; Example .......: No
; ===============================================================================================================================
Func __FileGetMime_GetDB($iIANA_NonStrict = False)
	; binarysearch is slower for small DBs, but much faster for bigger DBs (5k+ rows)
	; this has 850+ rows, therefore stringregexp is simpler to implement and maintain
	Local Static $sIANA_NonStrict = ""
	Local Static $sIANA_Strict = "|ai;application/postscript|aif;audio/x-aiff|aifc;audio/x-aiff|aiff;audio/x-aiff|asc;text/plain|atom;application/atom+xml|au;audio/basic|avi;video/x-msvideo|bcpio;application/x-bcpio|bin;application/octet-stream|bmp;image/bmp|cdf;application/x-netcdf|cgm;image/cgm|class;application/octet-stream|cpio;application/x-cpio|cpt;application/mac-compactpro|csh;application/x-csh|css;text/css|dcr;application/x-director|dif;video/x-dv|dir;application/x-director|djv;image/vnd.djvu|djvu;image/vnd.djvu|dll;application/octet-stream|dmg;application/octet-stream|dms;application/octet-stream|doc;application/msword|dtd;application/xml-dtd|dv;video/x-dv|dvi;application/x-dvi|dxr;application/x-director|eps;application/postscript|etx;text/x-setext|exe;application/octet-stream|ez;application/andrew-inset|gif;image/gif|gram;application/srgs|grxml;application/srgs+xml|gtar;application/x-gtar|hdf;application/x-hdf|hqx;application/mac-binhex40|htm;text/html|html;text/html|ice;x-conference/x-cooltalk|ico;image/x-icon|ics;text/calendar|ief;image/ief|ifb;text/calendar|iges;model/iges|igs;model/iges|jnlp;application/x-java-jnlp-file|jp2;image/jp2|jpe;image/jpeg|jpeg;image/jpeg|jpg;image/jpeg|js;application/x-javascript|kar;audio/midi|latex;application/x-latex|lha;application/octet-stream|lzh;application/octet-stream|m3u;audio/x-mpegurl|m4a;audio/mp4a-latm|m4b;audio/mp4a-latm|m4p;audio/mp4a-latm|m4u;video/vnd.mpegurl|m4v;video/x-m4v|mac;image/x-macpaint|man;application/x-troff-man|mathml;application/mathml+xml|me;application/x-troff-me|mesh;model/mesh|mid;audio/midi|midi;audio/midi|mif;application/vnd.mif|mov;video/quicktime|movie;video/x-sgi-movie|mp2;audio/mpeg|mp3;audio/mpeg|mp4;video/mp4|mpe;video/mpeg|mpeg;video/mpeg|mpg;video/mpeg|mpga;audio/mpeg|ms;application/x-troff-ms|msh;model/mesh|mxu;video/vnd.mpegurl|nc;application/x-netcdf|oda;application/oda|ogg;application/ogg|pbm;image/x-portable-bitmap|pct;image/pict|"
	If Not $sIANA_NonStrict Then
		$sIANA_Strict &= "pdb;chemical/x-pdb|pdf;application/pdf|pgm;image/x-portable-graymap|pgn;application/x-chess-pgn|pic;image/pict|pict;image/pict|png;image/png|pnm;image/x-portable-anymap|pnt;image/x-macpaint|pntg;image/x-macpaint|ppm;image/x-portable-pixmap|ppt;application/vnd.ms-powerpoint|ps;application/postscript|qt;video/quicktime|qti;image/x-quicktime|qtif;image/x-quicktime|ra;audio/x-pn-realaudio|ram;audio/x-pn-realaudio|ras;image/x-cmu-raster|rdf;application/rdf+xml|rgb;image/x-rgb|rm;application/vnd.rn-realmedia|roff;application/x-troff|rtf;text/rtf|rtx;text/richtext|sgm;text/sgml|sgml;text/sgml|sh;application/x-sh|shar;application/x-shar|silo;model/mesh|sit;application/x-stuffit|skd;application/x-koan|skm;application/x-koan|skp;application/x-koan|skt;application/x-koan|smi;application/smil|smil;application/smil|snd;audio/basic|so;application/octet-stream|spl;application/x-futuresplash|src;application/x-wais-source|sv4cpio;application/x-sv4cpio|sv4crc;application/x-sv4crc|svg;image/svg+xml|swf;application/x-shockwave-flash|t;application/x-troff|tar;application/x-tar|tcl;application/x-tcl|tex;application/x-tex|texi;application/x-texinfo|texinfo;application/x-texinfo|tif;image/tiff|tiff;image/tiff|tr;application/x-troff|tsv;text/tab-separated-values|txt;text/plain|ustar;application/x-ustar|vcd;application/x-cdlink|vrml;model/vrml|vxml;application/voicexml+xml|wav;audio/x-wav|wbmp;image/vnd.wap.wbmp|wbmxl;application/vnd.wap.wbxml|wml;text/vnd.wap.wml|wmlc;application/vnd.wap.wmlc|wmls;text/vnd.wap.wmlscript|wmlsc;application/vnd.wap.wmlscriptc|wrl;model/vrml|xbm;image/x-xbitmap|xht;application/xhtml+xml|xhtml;application/xhtml+xml|xls;application/vnd.ms-excel|xml;application/xml|xpm;image/x-xpixmap|xsl;application/xml|xslt;application/xslt+xml|xul;application/vnd.mozilla.xul+xml|xwd;image/x-xwindowdump|xyz;chemical/x-xyz|zip;application/zip|"
		$sIANA_NonStrict = ".123;application/vnd.lotus-1-2-3|3dml;text/vnd.in3d.3dml|3g2;video/3gpp2|3gp;video/3gpp|aab;application/x-authorware-bin|aac;audio/x-aac|aam;application/x-authorware-map|a;application/octet-stream|aas;application/x-authorware-seg|abw;application/x-abiword|acc;application/vnd.americandynamics.acc|ace;application/x-ace-compressed|acu;application/vnd.acucobol|acutc;application/vnd.acucorp|adp;audio/adpcm|aep;application/vnd.audiograph|afm;application/x-font-type1|afp;application/vnd.ibm.modcap|air;application/vnd.adobe.air-application-installer-package+zip|ami;application/vnd.amiga.ami|apk;application/vnd.android.package-archive|application;application/x-ms-application|apr;application/vnd.lotus-approach|asc;application/pgp-signature|asc;text/plain|asf;video/x-ms-asf|asm;text/x-asm|aso;application/vnd.accpac.simply.aso|asx;video/x-ms-asf|atc;application/vnd.acucorp|atomcat;application/atomcat+xml|atomsvc;application/atomsvc+xml|atx;application/vnd.antix.game-component|aw;application/applixware|azf;application/vnd.airzip.filesecure.azf|azs;application/vnd.airzip.filesecure.azs|azw;application/vnd.amazon.ebook|bat;application/x-msdownload|bdf;application/x-font-bdf|bdm;application/vnd.syncml.dm+wbxml|bh2;application/vnd.fujitsu.oasysprs|bmi;application/vnd.bmi|book;application/vnd.framemaker|box;application/vnd.previewsystems.box|boz;application/x-bzip2|bpk;application/octet-stream|btif;image/prs.btif|bz2;application/x-bzip2|bz;application/x-bzip|c4d;application/vnd.clonk.c4group|c4f;application/vnd.clonk.c4group|c4g;application/vnd.clonk.c4group|c4p;application/vnd.clonk.c4group|c4u;application/vnd.clonk.c4group|cab;application/vnd.ms-cab-compressed|car;application/vnd.curl.car|cat;application/vnd.ms-pki.seccat|cct;application/x-director|cc;text/x-c|ccxml;application/ccxml+xml|cdbcmsg;application/vnd.contact.cmsg|cdkey;application/vnd.mediastation.cdkey|cdx;chemical/x-cdx|cdxml;application/vnd.chemdraw+xml|cdy;application/vnd.cinderella|cer;application/pkix-cert|chat;application/x-chat|chm;application/vnd.ms-htmlhelp|"
		$sIANA_NonStrict &= "chrt;application/vnd.kde.kchart|cif;chemical/x-cif|cii;application/vnd.anser-web-certificate-issue-initiation|cil;application/vnd.ms-artgalry|cla;application/vnd.claymore|clkk;application/vnd.crick.clicker.keyboard|clkp;application/vnd.crick.clicker.palette|clkt;application/vnd.crick.clicker.template|clkw;application/vnd.crick.clicker.wordbank|clkx;application/vnd.crick.clicker|clp;application/x-msclip|cmc;application/vnd.cosmocaller|cmdf;chemical/x-cmdf|cml;chemical/x-cml|cmp;application/vnd.yellowriver-custom-menu|cmx;image/x-cmx|cod;application/vnd.rim.cod|com;application/x-msdownload|conf;text/plain|cpp;text/x-c|crd;application/x-mscardfile|crl;application/pkix-crl|crt;application/x-x509-ca-cert|csml;chemical/x-csml|csp;application/vnd.commonspace|cst;application/x-director|csv;text/csv|c;text/x-c|cu;application/cu-seeme|curl;text/vnd.curl|cww;application/prs.cww|cxt;application/x-director|cxx;text/x-c|daf;application/vnd.mobius.daf|dataless;application/vnd.fdsn.seed|davmount;application/davmount+xml|dcurl;text/vnd.curl.dcurl|dd2;application/vnd.oma.dd2+xml|ddd;application/vnd.fujixerox.ddd|deb;application/x-debian-package|def;text/plain|deploy;application/octet-stream|der;application/x-x509-ca-cert|dfac;application/vnd.dreamfactory|dic;text/x-c|diff;text/plain|dif;video/x-dv|dis;application/vnd.mobius.dis|dist;application/octet-stream|distz;application/octet-stream|dna;application/vnd.dna|docm;application/vnd.ms-word.document.macroenabled.12|docx;application/vnd.openxmlformats-officedocument.wordprocessingml.document|dot;application/msword|dotm;application/vnd.ms-word.template.macroenabled.12|dotx;application/vnd.openxmlformats-officedocument.wordprocessingml.template|dp;application/vnd.osgi.dp|dpg;application/vnd.dpgraph|dsc;text/prs.lines.tag|dtb;application/x-dtbook+xml|dts;audio/vnd.dts|dtshd;audio/vnd.dts.hd|dump;application/octet-stream|dv;video/x-dv|dwf;model/vnd.dwf|dwg;image/vnd.dwg|dxf;image/vnd.dxf|dxp;application/vnd.spotfire.dxp|ecma;application/ecmascript|edm;application/vnd.novadigm.edm|"
		$sIANA_NonStrict &= "edx;application/vnd.novadigm.edx|efif;application/vnd.picsel|ei6;application/vnd.pg.osasli|elc;application/octet-stream|eml;message/rfc822|emma;application/emma+xml|eol;audio/vnd.digital-winds|eot;application/vnd.ms-fontobject|epub;application/epub+zip|es3;application/vnd.eszigno3+xml|esf;application/vnd.epson.esf|et3;application/vnd.eszigno3+xml|ext;application/vnd.novadigm.ext|ez2;application/vnd.ezpix-album|ez3;application/vnd.ezpix-package|f4v;video/x-f4v|f77;text/x-fortran|f90;text/x-fortran|fbs;image/vnd.fastbidsheet|fdf;application/vnd.fdf|fe_launch;application/vnd.denovo.fcselayout-link|fg5;application/vnd.fujitsu.oasysgp|fgd;application/x-director|fh4;image/x-freehand|fh5;image/x-freehand|fh7;image/x-freehand|fhc;image/x-freehand|fh;image/x-freehand|fig;application/x-xfig|fli;video/x-fli|flo;application/vnd.micrografx.flo|flv;video/x-flv|flw;application/vnd.kde.kivio|flx;text/vnd.fmi.flexstor|fly;text/vnd.fly|fm;application/vnd.framemaker|fnc;application/vnd.frogans.fnc|for;text/x-fortran|fpx;image/vnd.fpx|frame;application/vnd.framemaker|fsc;application/vnd.fsc.weblaunch|fst;image/vnd.fst|ftc;application/vnd.fluxtime.clip|f;text/x-fortran|fti;application/vnd.anser-web-funds-transfer-initiation|fvt;video/vnd.fvt|fzs;application/vnd.fuzzysheet|g3;image/g3fax|gac;application/vnd.groove-account|gdl;model/vnd.gdl|geo;application/vnd.dynageo|gex;application/vnd.geometry-explorer|ggb;application/vnd.geogebra.file|ggt;application/vnd.geogebra.tool|ghf;application/vnd.groove-help|gim;application/vnd.groove-identity-message|gmx;application/vnd.gmx|gnumeric;application/x-gnumeric|gph;application/vnd.flographit|gqf;application/vnd.grafeq|gqs;application/vnd.grafeq|gre;application/vnd.geometry-explorer|grv;application/vnd.groove-injector|gsf;application/x-font-ghostscript|gtm;application/vnd.groove-tool-message|gtw;model/vnd.gtw|gv;text/vnd.graphviz|gz;application/x-gzip|h261;video/h261|h263;video/h263|h264;video/h264|hbci;application/vnd.hbci|hh;text/x-c|hlp;application/winhlp|hpgl;application/vnd.hp-hpgl|"
		$sIANA_NonStrict &= "hpid;application/vnd.hp-hpid|hps;application/vnd.hp-hps|h;text/x-c|htke;application/vnd.kenameaapp|hvd;application/vnd.yamaha.hv-dic|hvp;application/vnd.yamaha.hv-voice|hvs;application/vnd.yamaha.hv-script|icc;application/vnd.iccprofile|icm;application/vnd.iccprofile|ifm;application/vnd.shana.informed.formdata|igl;application/vnd.igloader|igx;application/vnd.micrografx.igx|iif;application/vnd.shana.informed.interchange|imp;application/vnd.accpac.simply.imp|ims;application/vnd.ms-ims|in;text/plain|ipk;application/vnd.shana.informed.package|irm;application/vnd.ibm.rights-management|irp;application/vnd.irepository.package+xml|iso;application/octet-stream|itp;application/vnd.shana.informed.formtemplate|ivp;application/vnd.immervision-ivp|ivu;application/vnd.immervision-ivu|jad;text/vnd.sun.j2me.app-descriptor|jam;application/vnd.jam|jar;application/java-archive|java;text/x-java-source|jisp;application/vnd.jisp|jlt;application/vnd.hp-jlyt|joda;application/vnd.joost.joda-archive|jp2;image/jp2|jpgm;video/jpm|jpgv;video/jpeg|jpm;video/jpm|json;application/json|karbon;application/vnd.kde.karbon|kfo;application/vnd.kde.kformula|kia;application/vnd.kidspiration|kil;application/x-killustrator|kml;application/vnd.google-earth.kml+xml|kmz;application/vnd.google-earth.kmz|kne;application/vnd.kinar|knp;application/vnd.kinar|kon;application/vnd.kde.kontour|kpr;application/vnd.kde.kpresenter|kpt;application/vnd.kde.kpresenter|ksh;text/plain|ksp;application/vnd.kde.kspread|ktr;application/vnd.kahootz|ktz;application/vnd.kahootz|kwd;application/vnd.kde.kword|kwt;application/vnd.kde.kword|lbd;application/vnd.llamagraphics.life-balance.desktop|lbe;application/vnd.llamagraphics.life-balance.exchange+xml|les;application/vnd.hhe.lesson-player|link66;application/vnd.route66.link66+xml|list3820;application/vnd.ibm.modcap|listafp;application/vnd.ibm.modcap|list;text/plain|log;text/plain|lostxml;application/lost+xml|lrf;application/octet-stream|lrm;application/vnd.ms-lrm|ltf;application/vnd.frogans.ltf|lvp;audio/vnd.lucent.voice|"
		$sIANA_NonStrict &= "lwp;application/vnd.lotus-wordpro|m13;application/x-msmediaview|m14;application/x-msmediaview|m1v;video/mpeg|m2a;audio/mpeg|m2v;video/mpeg|m3a;audio/mpeg|m4a;audio/mp4a-latm|m4b;audio/mp4a-latm|m4p;audio/mp4a-latm|ma;application/mathematica|mac;image/x-macpaint|mag;application/vnd.ecowin.chart|maker;application/vnd.framemaker|man;application/x-troff-man|man;text/troff|mb;application/mathematica|mbk;application/vnd.mobius.mbk|mbox;application/mbox|mc1;application/vnd.medcalcdata|mcd;application/vnd.mcd|mcurl;text/vnd.curl.mcurl|mdb;application/x-msaccess|mdi;image/vnd.ms-modi|me;application/x-troff-me|me;text/troff|mfm;application/vnd.mfmp|mgz;application/vnd.proteus.magazine|mht;message/rfc822|mhtml;message/rfc822|mime;message/rfc822|mj2;video/mj2|mjp2;video/mj2|mlp;application/vnd.dolby.mlp|mmd;application/vnd.chipnuts.karaoke-mmd|mmf;application/vnd.smaf|mmr;image/vnd.fujixerox.edmics-mmr|mny;application/x-msmoney|mobi;application/x-mobipocket-ebook|mp2a;audio/mpeg|mp4a;audio/mp4|mp4s;application/mp4|mp4v;video/mp4|mpa;video/mpeg|mpc;application/vnd.mophun.certificate|mpg4;video/mp4|mpkg;application/vnd.apple.installer+xml|mpm;application/vnd.blueice.multipass|mpn;application/vnd.mophun.application|mpp;application/vnd.ms-project|mpt;application/vnd.ms-project|mpy;application/vnd.ibm.minipay|mqy;application/vnd.mobius.mqy|mrc;application/marc|ms;application/x-troff-ms|mscml;application/mediaservercontrol+xml|mseed;application/vnd.fdsn.mseed|mseq;application/vnd.mseq|msf;application/vnd.epson.msf|msi;application/x-msdownload|msl;application/vnd.mobius.msl|ms;text/troff|msty;application/vnd.muvee.style|mts;model/vnd.mts|mus;application/vnd.musician|musicxml;application/vnd.recordare.musicxml+xml|mvb;application/x-msmediaview|mwf;application/vnd.mfer|mxf;application/mxf|mxl;application/vnd.recordare.musicxml|mxml;application/xv+xml|mxs;application/vnd.triscape.mxs|nb;application/mathematica|ncx;application/x-dtbncx+xml|n-gage;application/vnd.nokia.n-gage.symbian.install|ngdat;application/vnd.nokia.n-gage.data|"
		$sIANA_NonStrict &= "nlu;application/vnd.neurolanguage.nlu|nml;application/vnd.enliven|nnd;application/vnd.noblenet-directory|nns;application/vnd.noblenet-sealer|nnw;application/vnd.noblenet-web|npx;image/vnd.net-fpx|nsf;application/vnd.lotus-notes|nws;message/rfc822|oa2;application/vnd.fujitsu.oasys2|oa3;application/vnd.fujitsu.oasys3|o;application/octet-stream|oas;application/vnd.fujitsu.oasys|obd;application/x-msbinder|obj;application/octet-stream|odb;application/vnd.oasis.opendocument.database|odc;application/vnd.oasis.opendocument.chart|odf;application/vnd.oasis.opendocument.formula|odft;application/vnd.oasis.opendocument.formula-template|odg;application/vnd.oasis.opendocument.graphics|odi;application/vnd.oasis.opendocument.image|odp;application/vnd.oasis.opendocument.presentation|ods;application/vnd.oasis.opendocument.spreadsheet|odt;application/vnd.oasis.opendocument.text|oga;audio/ogg|ogv;video/ogg|ogx;application/ogg|onepkg;application/onenote|onetmp;application/onenote|opf;application/oebps-package+xml|oprc;application/vnd.palm|org;application/vnd.lotus-organizer|osf;application/vnd.yamaha.openscoreformat|osfpvg;application/vnd.yamaha.openscoreformat.osfpvg+xml|otc;application/vnd.oasis.opendocument.chart-template|otf;application/x-font-otf|otg;application/vnd.oasis.opendocument.graphics-template|oth;application/vnd.oasis.opendocument.text-web|oti;application/vnd.oasis.opendocument.image-template|otm;application/vnd.oasis.opendocument.text-master|otp;application/vnd.oasis.opendocument.presentation-template|ots;application/vnd.oasis.opendocument.spreadsheet-template|ott;application/vnd.oasis.opendocument.text-template|oxt;application/vnd.openofficeorg.extension|p10;application/pkcs10|p12;application/x-pkcs12|p7b;application/x-pkcs7-certificates|p7c;application/pkcs7-mime|p7m;application/pkcs7-mime|p7r;application/x-pkcs7-certreqresp|p7s;application/pkcs7-signature|pas;text/x-pascal|pbd;application/vnd.powerbuilder6|pcf;application/x-font-pcf|pcl;application/vnd.hp-pcl|pclxl;application/vnd.hp-pclxl|"
		$sIANA_NonStrict &= "pcurl;application/vnd.curl.pcurl|pcx;image/x-pcx|pdb;application/vnd.palm|pdb;chemical/x-pdb|pfa;application/x-font-type1|pfb;application/x-font-type1|pfm;application/x-font-type1|pfr;application/font-tdpfr|pfx;application/x-pkcs12|pgp;application/pgp-encrypted|php;text/x-php|pict;image/pict|pkg;application/octet-stream|pki;application/pkixcmp|pkipath;application/pkix-pkipath|plb;application/vnd.3gpp.pic-bw-large|plc;application/vnd.mobius.plc|plf;application/vnd.pocketlearn|pls;application/pls+xml|pl;text/plain|pml;application/vnd.ctc-posml|pntg;image/x-macpaint|pnt;image/x-macpaint|portpkg;application/vnd.macports.portpkg|pot;application/vnd.ms-powerpoint|potm;application/vnd.ms-powerpoint.template.macroenabled.12|potx;application/vnd.openxmlformats-officedocument.presentationml.template|ppa;application/vnd.ms-powerpoint|ppam;application/vnd.ms-powerpoint.addin.macroenabled.12|ppd;application/vnd.cups-ppd|pps;application/vnd.ms-powerpoint|ppsm;application/vnd.ms-powerpoint.slideshow.macroenabled.12|ppsx;application/vnd.openxmlformats-officedocument.presentationml.slideshow|pptm;application/vnd.ms-powerpoint.presentation.macroenabled.12|pptx;application/vnd.openxmlformats-officedocument.presentationml.presentation|pqa;application/vnd.palm|prc;application/x-mobipocket-ebook|pre;application/vnd.lotus-freelance|prf;application/pics-rules|psb;application/vnd.3gpp.pic-bw-small|psd;image/vnd.adobe.photoshop|psf;application/x-font-linux-psf|p;text/x-pascal|ptid;application/vnd.pvi.ptid1|pub;application/x-mspublisher|pvb;application/vnd.3gpp.pic-bw-var|pwn;application/vnd.3m.post-it-notes|pwz;application/vnd.ms-powerpoint|pya;audio/vnd.ms-playready.media.pya|pyc;application/x-python-code|pyo;application/x-python-code|py;text/x-python|pyv;video/vnd.ms-playready.media.pyv|qam;application/vnd.epson.quickanime|qbo;application/vnd.intu.qbo|qfx;application/vnd.intu.qfx|qps;application/vnd.publishare-delta-tree|qtif;image/x-quicktime|qti;image/x-quicktime|qwd;application/vnd.quark.quarkxpress|qwt;application/vnd.quark.quarkxpress|"
		$sIANA_NonStrict &= "qxb;application/vnd.quark.quarkxpress|qxd;application/vnd.quark.quarkxpress|qxl;application/vnd.quark.quarkxpress|qxt;application/vnd.quark.quarkxpress|rar;application/x-rar-compressed|rcprofile;application/vnd.ipunplugged.rcprofile|rdz;application/vnd.data-vision.rdz|rep;application/vnd.businessobjects|res;application/x-dtbresource+xml|rif;application/reginfo+xml|rl;application/resource-lists+xml|rlc;image/vnd.fujixerox.edmics-rlc|rld;application/resource-lists-diff+xml|rmi;audio/midi|rmp;audio/x-pn-realaudio-plugin|rms;application/vnd.jcp.javame.midlet-rms|rnc;application/relax-ng-compact-syntax|rpm;application/x-rpm|rpss;application/vnd.nokia.radio-presets|rpst;application/vnd.nokia.radio-preset|rq;application/sparql-query|rs;application/rls-services+xml|rsd;application/rsd+xml|rss;application/rss+xml|rtf;application/rtf|rtf;text/rtf|saf;application/vnd.yamaha.smaf-audio|sbml;application/sbml+xml|sc;application/vnd.ibm.secure-container|scd;application/x-msschedule|scm;application/vnd.lotus-screencam|scq;application/scvp-cv-request|scs;application/scvp-cv-response|scurl;text/vnd.curl.scurl|sda;application/vnd.stardivision.draw|sdc;application/vnd.stardivision.calc|sdd;application/vnd.stardivision.impress|sdkd;application/vnd.solent.sdkm+xml|sdkm;application/vnd.solent.sdkm+xml|sdp;application/sdp|sdw;application/vnd.stardivision.writer|see;application/vnd.seemail|seed;application/vnd.fdsn.seed|sema;application/vnd.sema|semd;application/vnd.semd|semf;application/vnd.semf|ser;application/java-serialized-object|setpay;application/set-payment-initiation|setreg;application/set-registration-initiation|sfd-hdstx;application/vnd.hydrostatix.sof-data|sfs;application/vnd.spotfire.sfs|sgl;application/vnd.stardivision.writer-global|shf;application/shf+xml|sic;application/vnd.wap.sic|sig;application/pgp-signature|sis;application/vnd.symbian.install|sisx;application/vnd.symbian.install|si;text/vnd.wap.si|sitx;application/x-stuffitx|slc;application/vnd.wap.slc|sldm;application/vnd.ms-powerpoint.slide.macroenabled.12|"
		$sIANA_NonStrict &= "sldx;application/vnd.openxmlformats-officedocument.presentationml.slide|slt;application/vnd.epson.salt|sl;text/vnd.wap.sl|smf;application/vnd.stardivision.math|snf;application/x-font-snf|spc;application/x-pkcs7-certificates|spf;application/vnd.yamaha.smaf-phrase|spot;text/vnd.in3d.spot|spp;application/scvp-vp-response|spq;application/scvp-vp-request|spx;audio/ogg|srx;application/sparql-results+xml|sse;application/vnd.kodak-descriptor|ssf;application/vnd.epson.ssf|ssml;application/ssml+xml|stc;application/vnd.sun.xml.calc.template|std;application/vnd.sun.xml.draw.template|s;text/x-asm|stf;application/vnd.wt.stf|sti;application/vnd.sun.xml.impress.template|stk;application/hyperstudio|stl;application/vnd.ms-pki.stl|str;application/vnd.pg.format|stw;application/vnd.sun.xml.writer.template|sus;application/vnd.sus-calendar|susp;application/vnd.sus-calendar|svd;application/vnd.svd|svgz;image/svg+xml|swa;application/x-director|swi;application/vnd.arastra.swi|sxc;application/vnd.sun.xml.calc|sxd;application/vnd.sun.xml.draw|sxg;application/vnd.sun.xml.writer.global|sxi;application/vnd.sun.xml.impress|sxm;application/vnd.sun.xml.math|sxw;application/vnd.sun.xml.writer|tao;application/vnd.tao.intent-module-archive|t;application/x-troff|tcap;application/vnd.3gpp2.tcap|teacher;application/vnd.smart.teacher|text;text/plain|tfm;application/x-tex-tfm|tgz;application/x-gzip|tmo;application/vnd.tmobile-livetv|torrent;application/x-bittorrent|tpl;application/vnd.groove-tool-template|tpt;application/vnd.trid.tpt|tra;application/vnd.trueapp|tr;application/x-troff|trm;application/x-msterminal|tr;text/troff|ttc;application/x-font-ttf|t;text/troff|ttf;application/x-font-ttf|twd;application/vnd.simtech-mindmapper|twds;application/vnd.simtech-mindmapper|txd;application/vnd.genomatix.tuxedo|txf;application/vnd.mobius.txf|u32;application/x-authorware-bin|udeb;application/x-debian-package|ufd;application/vnd.ufdl|ufdl;application/vnd.ufdl|umj;application/vnd.umajin|unityweb;application/vnd.unity|uoml;application/vnd.uoml+xml|"
		$sIANA_NonStrict &= "uris;text/uri-list|uri;text/uri-list|urls;text/uri-list|utz;application/vnd.uiq.theme|uu;text/x-uuencode|vcf;text/x-vcard|vcg;application/vnd.groove-vcard|vcs;text/x-vcalendar|vcx;application/vnd.vcx|vis;application/vnd.visionary|viv;video/vnd.vivo|vor;application/vnd.stardivision.writer|vox;application/x-authorware-bin|vsd;application/vnd.visio|vsf;application/vnd.vsf|vss;application/vnd.visio|vst;application/vnd.visio|vsw;application/vnd.visio|vtu;model/vnd.vtu|w3d;application/x-director|wad;application/x-doom|wax;audio/x-ms-wax|wbmxl;application/vnd.wap.wbxml|wbs;application/vnd.criticaltools.wbs+xml|wbxml;application/vnd.wap.wbxml|wcm;application/vnd.ms-works|wdb;application/vnd.ms-works|wiz;application/msword|wks;application/vnd.ms-works|wma;audio/x-ms-wma|wmd;application/x-ms-wmd|wmf;application/x-msmetafile|wm;video/x-ms-wm|wmv;video/x-ms-wmv|wmx;video/x-ms-wmx|wmz;application/x-ms-wmz|wpd;application/vnd.wordperfect|wpl;application/vnd.ms-wpl|wps;application/vnd.ms-works|wqd;application/vnd.wqd|wri;application/x-mswrite|wsdl;application/wsdl+xml|wspolicy;application/wspolicy+xml|wtb;application/vnd.webturbo|wvx;video/x-ms-wvx|x32;application/x-authorware-bin|x3d;application/vnd.hzn-3d-crossword|xap;application/x-silverlight-app|xar;application/vnd.xara|xbap;application/x-ms-xbap|xbd;application/vnd.fujixerox.docuworks.binder|xdm;application/vnd.syncml.dm+xml|xdp;application/vnd.adobe.xdp+xml|xdw;application/vnd.fujixerox.docuworks|xenc;application/xenc+xml|xer;application/patch-ops-error+xml|xfdf;application/vnd.adobe.xfdf|xfdl;application/vnd.xfdl|xhvml;application/xv+xml|xif;image/vnd.xiff|xla;application/vnd.ms-excel|xlam;application/vnd.ms-excel.addin.macroenabled.12|xlb;application/vnd.ms-excel|xlc;application/vnd.ms-excel|xlm;application/vnd.ms-excel|xlsb;application/vnd.ms-excel.sheet.binary.macroenabled.12|xlsm;application/vnd.ms-excel.sheet.macroenabled.12|xlsx;application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|xlt;application/vnd.ms-excel|"
		$sIANA_NonStrict &= "xltm;application/vnd.ms-excel.template.macroenabled.12|xltx;application/vnd.openxmlformats-officedocument.spreadsheetml.template|xlw;application/vnd.ms-excel|xo;application/vnd.olpc-sugar|xop;application/xop+xml|xpdl;application/xml|xpi;application/x-xpinstall|xpr;application/vnd.is-xpr|xps;application/vnd.ms-xpsdocument|xpw;application/vnd.intercon.formnet|xpx;application/vnd.intercon.formnet|xsm;application/vnd.syncml+xml|xspf;application/xspf+xml|xvm;application/xv+xml|xvml;application/xv+xml|zaz;application/vnd.zzazz.deck+xml|zir;application/vnd.zul|zirz;application/vnd.zul|zmm;application/vnd.handheld-entertainment+xml|"
	EndIf
	Return $sIANA_Strict & ($iIANA_NonStrict ? $sIANA_NonStrict : "")
EndFunc   ;==>__FileGetMime_GetDB
