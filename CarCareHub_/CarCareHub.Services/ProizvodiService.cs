using AutoMapper;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public class ProizvodiService : BaseCRUDService<Model.Proizvod, Database.Proizvod, ProizvodiSearchObject, ProizvodiInsert, ProizvodiUpdate>,  IProizvodiService
    {
        public ProizvodiService(Database.CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {

        }
    }
}
