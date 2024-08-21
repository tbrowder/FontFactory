use Test;

use FontFactory;
use FontFactory::Args;
use FontFactory::FontClasses;
use FontFactory::OtherClasses;
use FontFactory::Config;
use FontFactory::Resources;
use FontFactory::Roles;
use FontFactory::PageProcs;
use FontFactory::Utils;
use FontFactory::FontUtils; # to become its own repo later
use FontFactory::PodUtils;
use FontFactory::BuildUtils; # to be removed

use-ok "FontFactory";
use-ok "FontFactory::Args";
use-ok "FontFactory::FontClasses";
use-ok "FontFactory::OtherClasses";
use-ok "FontFactory::Config";
use-ok "FontFactory::Resources";
use-ok "FontFactory::Roles";
use-ok "FontFactory::Utils";
use-ok "FontFactory::PageProcs";
use-ok "FontFactory::FontUtils"; # to become its own repo later
use-ok "FontFactory::PodUtils";
use-ok "FontFactory::BuildUtils"; # to be removed

done-testing;
