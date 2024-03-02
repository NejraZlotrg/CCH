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

    public class ZaposlenikService : BaseService<Model.Zaposlenik, Database.Zaposlenik, GradSearchObject> ,IZaposlenikService
    {




        public ZaposlenikService(Database.CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {

        }


      


    }
}

