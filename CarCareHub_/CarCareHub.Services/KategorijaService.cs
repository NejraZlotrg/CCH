using AutoMapper;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services.Database;
using Microsoft.EntityFrameworkCore;
using System.Linq;

namespace CarCareHub.Services
{
    public class KategorijaService : BaseCRUDService<Model.Kategorija, Database.Kategorija, KategorijaSearchObject, KategorijaInsert, KategorijaUpdate>, IKategorijaService
    {
        public KategorijaService(Database.CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
        }

        public override IQueryable<Database.Kategorija> AddFilter(IQueryable<Database.Kategorija> query, KategorijaSearchObject search = null)
        {
            if (!string.IsNullOrWhiteSpace(search?.NazivKategorije))
            {
                query = query.Where(x => x.NazivKategorije.StartsWith(search.NazivKategorije));
            }
            return base.AddFilter(query, search);
        }

    }
}
