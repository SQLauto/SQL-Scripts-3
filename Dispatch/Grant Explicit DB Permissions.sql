--set nocount on
use sdmconfig
Select 'GRANT EXECUTE ON dbo.' +
[name] + ' TO dmconfig'
from sysobjects where type = 'p'
union all
Select 'GRANT SELECT,UPDATE,INSERT ON dbo.' +
[name] + ' TO dmconfig'
from sysobjects where type = 'u'
union all
Select 'GRANT EXECUTE ON dbo.' +
[name] + ' TO dmweb'
from sysobjects where type = 'p'
union all
Select 'GRANT SELECT,UPDATE,INSERT ON dbo.' +
[name] + ' TO dmweb'
from sysobjects where type = 'u'

use sdmdata
Select 'GRANT EXECUTE ON dbo.' +
[name] + ' TO dmconfig'
from sysobjects where type = 'p'
union all
Select 'GRANT SELECT,UPDATE,INSERT ON dbo.' +
[name] + ' TO dmconfig'
from sysobjects where type = 'u'
union all
Select 'GRANT EXECUTE ON dbo.' +
[name] + ' TO dmweb'
from sysobjects where type = 'p'
union all
Select 'GRANT SELECT,UPDATE,INSERT ON dbo.' +
[name] + ' TO dmweb'
from sysobjects where type = 'u'