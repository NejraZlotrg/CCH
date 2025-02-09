using AutoMapper;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services.Database;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System.Linq;

namespace CarCareHub.Services
{
    public class KategorijaService : BaseCRUDService<Model.Kategorija, Database.Kategorija, KategorijaSearchObject, KategorijaInsert, KategorijaUpdate>, IKategorijaService
    {
        public KategorijaService(Database.CchV2AliContext dbContext, IMapper mapper, IHttpContextAccessor httpContextAccessor) : base(dbContext, mapper, httpContextAccessor)
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
