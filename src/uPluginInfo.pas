unit uPluginInfo;

interface

uses uStatus;

const
  IDPlugin: TGUID = '{B8844594-D8A7-4C17-A62B-AA8CC66C32AA}';
  PluginName: String = 'Service-plugin for Bittorrent-protocol';
  Author: String = 'AvtorFile';
  EmailAuthor: String = 'avtorfile@mail.ru';
  SiteAuthor: String = 'אגעמנפאיכ.נפ';
  PluginType: TPluginType = ptServicePlugin;

  // IServicePlugin
const
  ServiceName: String = 'bittorrent';
  Services: String = 'bittorrent';

var
  UrlSalePremium: String = '';
  UrlRefPremium: String = '';
  PremiumContent: Boolean = false;
  RecognitionUse: Boolean = false;

implementation

end.
