using CarCareHub.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public class ProizvodiService: IProizvodiService
    {
        CchV2AliContext dbContext;

        public ProizvodiService(CchV2AliContext dbContext)
        {
            this.dbContext = dbContext;
        }
        List<Proizvod> proizvods = new List<Proizvod>()
        {
            new Proizvod()
            {
                ProizvodId=1,
                Naziv="llll"
            }

        };

        public IList<Proizvod> Get()
        {
            var list = dbContext.Proizvods.ToList();
            return proizvods;
        }
    }
}
