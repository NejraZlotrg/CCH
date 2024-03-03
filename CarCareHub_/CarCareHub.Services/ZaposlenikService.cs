using AutoMapper;
using CarCareHub.Services.Database;
using CarCareHub.Model;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CarCareHub.Model.SearchObjects;

namespace CarCareHub.Services
{

    public class ZaposlenikService : BaseService<Model.Zaposlenik, Database.Zaposlenik, ZaposlenikSearchObject> ,IZaposlenikService
    {


        public ZaposlenikService(Database.CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {

        }

        public Model.Zaposlenik Insert(ZaposlenikInsert insert)
        {
            var entity = new Database.Zaposlenik();
            _mapper.Map(insert, entity);

            _dbContext.Zaposleniks.Add(entity);
            _dbContext.SaveChanges();
            return _mapper.Map<Model.Zaposlenik>(entity);
        }

        public Model.Zaposlenik Update(int id, ZaposlenikUpdate update)
        {
            var entity = _dbContext.Zaposleniks.Find(id);

            _mapper.Map(update, entity);

            _dbContext.SaveChanges();
            return _mapper.Map<Model.Zaposlenik>(entity);
        }

        public override IQueryable<Database.Zaposlenik> AddInclude(IQueryable<Database.Zaposlenik> query, ZaposlenikSearchObject? search = null)
        {
            if (search?.IsUlogeIncluded == true)
            {
                query = query.Include(entity => entity.Uloga); // Promijeniti "Uloges" u "Uloga" ako je ovo pravilno ime navigacijskog svojstva

            }
            return base.AddInclude(query, search);
        }



    }
}

