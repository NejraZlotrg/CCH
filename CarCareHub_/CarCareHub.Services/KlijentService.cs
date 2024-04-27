using AutoMapper;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CarCareHub.Services.Database;

namespace CarCareHub.Services
{
    public class KlijentService : BaseCRUDService<Model.Klijent, Database.Klijent, KlijentSearchObject, KlijentInsert, KlijentUpdate>, IKlijentService
    {
        CarCareHub.Services.Database.CchV2AliContext _dbContext;
        IMapper _mapper { get; set; }

        public KlijentService(CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
            _dbContext = dbContext;
            _mapper = mapper;
        }
        public override Task<Model.Klijent> Insert(Model.KlijentInsert insert)
        {
            return base.Insert(insert);
        }

        public override async Task<Model.Klijent> Update(int id, Model.KlijentUpdate update)
        {
            return await base.Update(id, update);
        }

        public override async Task<Model.Klijent> Delete(int id)
        {
            return await base.Delete(id);
        }


        public override IQueryable<Database.Klijent> AddInclude(IQueryable<Database.Klijent> query, KlijentSearchObject? search = null)
        {
            // Uključujemo samo entitet Uloge
            if (search?.IsAllIncluded == true)
            {
                query = query.Include(z => z.Grad);
                query = query.Include(z => z.Grad.Drzava);
                query = query.Include(z => z.ChatKlijentAutoserviss);
                query = query.Include(z => z.ChatKlijentZaposlenik);
            }
            return base.AddInclude(query, search);
        }

    }
}