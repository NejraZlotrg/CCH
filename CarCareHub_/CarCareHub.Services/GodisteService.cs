using AutoMapper;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public class GodisteService : BaseCRUDService<Model.Godiste, Database.Godiste, GodisteSearchObject, GodisteInsert, GodisteUpdate>, IGodisteService
    {
        public GodisteService(Database.CchV2AliContext dbContext, IMapper mapper, IHttpContextAccessor httpContextAccessor) : base(dbContext, mapper, httpContextAccessor)
        {
        }

        public override IQueryable<Database.Godiste> AddFilter(IQueryable<Database.Godiste> query, GodisteSearchObject? search = null)
        {

            
            if (search?.Godiste_!=null)
            {
                query = query.Where(x => x.Godiste_.ToString().StartsWith(search.Godiste_.ToString()));
            }
          
            return base.AddFilter(query, search);
        }

        //public override IQueryable<Database.Godiste> AddInclude(IQueryable<Database.Godiste> query, GodisteSearchObject? search = null)
        //{
        //    // Uključujemo samo entitet Uloge
        //    if (search?.IsAllIncluded == true)
        //    {
              
        //    }
        //    return base.AddInclude(query, search);
        //}
    }


}
