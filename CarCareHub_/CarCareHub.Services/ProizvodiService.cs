using AutoMapper;
using CarCareHub.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public class ProizvodiService : BaseCRUDService<Model.Proizvod, Proizvod, CarCareHub.Model.SearchObjects.ProizvodiSearchObject, Model.ProizvodiInsert, Model.ProizvodiUpdate>
        , IProizvodiService
    {
        public ProizvodiService(CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
        }
    }
}
