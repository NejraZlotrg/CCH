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
        public override Task<Model.Vozilo> Insert(Model.VoziloInsert insert)
        {
            return base.Insert(insert);
        }

        public override async Task<Model.Vozilo> Update(int id, Model.VoziloUpdate update)
        {
            return await base.Update(id, update);
        }

        public override async Task<Model.Vozilo> Delete(int id)
        {
            return await base.Delete(id);
        }

    }
}
