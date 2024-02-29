using AutoMapper;
using CarCareHub.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;


namespace CarCareHub.Services
{


    public class FirmaAutodijelovaService : IFirmaAutodijelovaService
    {
        CarCareHub.Services.Database.CchV2AliContext _dbContext;
        IMapper _mapper { get; set; }

        public FirmaAutodijelovaService(CchV2AliContext dbContext, IMapper mapper)
        {
            _dbContext = dbContext;
            _mapper = mapper;
        }

        List<FirmaAutodijelova> proizvods = new List<FirmaAutodijelova>()
        {
            new FirmaAutodijelova()
            {
                 NazivFirme="nn",
                 Telefon="6858n"

            }

        };

        public List<Model.FirmaAutodijelova> Get()
        {

            var list = _dbContext.FirmaAutodijelovas.ToList();

            var newList = new List<CarCareHub.Model.FirmaAutodijelova>();
            foreach (var item in list)
            {
                newList.Add(new Model.FirmaAutodijelova()
                {
                    NazivFirme = item.NazivFirme,
                    Telefon = item.Telefon,
                    Adresa = item.Adresa,
                    Email = item.Email,
                    FirmaId = item.FirmaId,
                    GradId = item.GradId,
                    Password = item.Password,
                    SlikaProfila = item.SlikaProfila
                });

            }
            return newList;
        }

        public Model.FirmaAutodijelova Add(Model.FirmaAutodijelovaInsert insert)
        {
            var firma = new FirmaAutodijelova();
            _mapper.Map(insert,firma);

            _dbContext.Add(firma);
            _dbContext.SaveChanges();

            return _mapper.Map<Model.FirmaAutodijelova>(firma);
        }

        public Model.FirmaAutodijelova Update(int id, Model.FirmaAutodijelovaUpdate update)
        {
            var temp = _dbContext.FirmaAutodijelovas.Find(id);
            _mapper.Map(update,temp);

            _dbContext.SaveChanges();
            return _mapper.Map<Model.FirmaAutodijelova>(temp);
           
        }


        //public static string GenerateSalt()
        //{
        //    RNGCryptoServiceProvider provider = new RNGCryptoServiceProvider();
        //    var byteArray = new byte[16];
        //   provider.GetBytes(byteArray);


        //    return Convert.ToBase64String(byteArray);
        //}
        //public static string GenerateHash(string salt, string password)
        //{
        //    byte[] src = Convert.FromBase64String(salt);
        //    byte[] bytes = Encoding.Unicode.GetBytes(password);
        //    byte[] dst = new byte[src.Length + bytes.Length];

        //    System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
        //    System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

        //    HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
        //    byte[] inArray = algorithm.ComputeHash(dst);
        //    return Convert.ToBase64String(inArray);
        //}


    }
}


       
       
    

