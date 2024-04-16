using AutoMapper;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public class VoziloService : BaseCRUDService<Model.Vozilo, Database.Vozilo, VoziloSearchObject, VoziloInsert, VoziloUpdate>, IVoziloService
    {
        public VoziloService(Database.CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
        }
      


        public override IQueryable<Database.Vozilo> AddFilter(IQueryable<Database.Vozilo> query, VoziloSearchObject? search = null)
        {


            if (!string.IsNullOrWhiteSpace(search?.MarkaVozila))
            {
                query = query.Where(x => x.MarkaVozila.StartsWith(search.MarkaVozila));
            }
            return base.AddFilter(query, search);
        }

     
    }
}
