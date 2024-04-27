using AutoMapper;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using CarCareHub.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace CarCareHub.Services
{
    public class AutoservisService : BaseCRUDService<Model.Autoservis, Database.Autoservis, AutoservisSearchObject, AutoservisInsert, AutoservisUpdate>, IAutoservisService
    {
        CarCareHub.Services.Database.CchV2AliContext _dbContext;
        IMapper _mapper { get; set; }

        public AutoservisService(CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
            _dbContext = dbContext;
            _mapper = mapper;
        }
        public override Task<Model.Autoservis> Insert(Model.AutoservisInsert insert)
        {
            return base.Insert(insert);
        }

        public override async Task<Model.Autoservis> Update(int id, Model.AutoservisUpdate update)
        {
            return await base.Update(id, update);
        }

        public override async Task<Model.Autoservis> Delete(int id)
        {
            return await base.Delete(id);
        }

        public override IQueryable<Database.Autoservis> AddInclude(IQueryable<Database.Autoservis> query, AutoservisSearchObject? search = null)
        {
            if (search?.IsAllIncluded == true)
            {
                query = query.Include(entity => entity.Grad);
                query = query.Include(entity => entity.Grad.Drzava);
                query = query.Include(entity => entity.Uloga);
                query = query.Include(entity => entity.Vozilo);
            }
            return base.AddInclude(query, search);
        }
    }
    }
