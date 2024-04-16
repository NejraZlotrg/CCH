using AutoMapper;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public class PorukaService: BaseCRUDService<Model.Poruka, Database.Poruka, PorukaSearchObject, PorukaInsert, PorukaUpdate>, IPorukaService
    {
        public PorukaService(Database.CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
        }

        public override IQueryable<Database.Poruka> AddFilter(IQueryable<Database.Poruka> query, PorukaSearchObject? search = null)
        {


            if (search?.Sadrzaj != null)
            {
                query = query.Where(x => x.Sadrzaj.Contains(search.Sadrzaj));
            }
            if (search?.ChatKlijentServisId != null)
            {
                query = query.Where(x => x.ChatKlijentServisId==search.ChatKlijentServisId);
            }


            return base.AddFilter(query, search);
        }

        public override IQueryable<Database.Poruka> AddInclude(IQueryable<Database.Poruka> query, PorukaSearchObject? search = null)
        {
            // Uključujemo samo entitet Uloge
            if (search?.IsAllIncluded == true)
            {
                query = query.Include(z => z.ChatKlijentServis);
                query = query.Include(z => z.ChatKlijentServis.Autoservis);
                query = query.Include(z => z.ChatKlijentServis.Klijent);
            }
            return base.AddInclude(query, search);
        }
    }

}
