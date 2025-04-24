
using AutoMapper;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services.Database;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using Microsoft.ML.Trainers;

namespace CarCareHub.Services
{
    public class RecommenderService : IRecommenderService
    {
        private readonly CchV2AliContext _dbContext;
        private static MLContext? _mlContext;
        private static object isLocked = new();
        private static ITransformer? _model; 
        private readonly IMapper _mapper;
        public RecommenderService(CchV2AliContext dbContext, IMapper mapper)
        {
            _dbContext = dbContext;
            _mapper = mapper;
        }
        public async Task<List<Database.Proizvod>> GetRecommendationsByProizvodId(long proizvodId, CancellationToken cancellationToken)
        {
            var entity = await _dbContext.Recommenders.FirstOrDefaultAsync(x => x.ProizvodId == proizvodId, cancellationToken);

            if (entity is null)
            {
                Console.WriteLine($"Nema preporuka za proizvod ID: {proizvodId}");
                return new();
            }
            var recommendedProizvodIds = new List<long>();

            recommendedProizvodIds.Add(entity.PrvaPreporukaId ?? 0);
            recommendedProizvodIds.Add(entity.DrugaPreporukaId ?? 0);
            recommendedProizvodIds.Add(entity.TrecaPreporukaId ?? 0);

            var proizvodi = await _dbContext.Proizvods
                .Where(x => recommendedProizvodIds.Contains(x.ProizvodId))
                .ToListAsync(cancellationToken);

            return proizvodi;
        }

        private List<Database.Proizvod> Recommend(long proizvodId)
        {
            lock (isLocked)
            {
                if (_mlContext == null)
                {
                    _mlContext = new MLContext();

                    var tmpData = _dbContext.NarudzbaStavkas.Include(x => x.Proizvod).ToList();

                    var data = new List<ProizvodRecommendation>();

                    foreach (var x in tmpData)
                    {
                        var distinctItemId = tmpData.Select(y => y.ProizvodId).ToList();

                        distinctItemId?.ForEach(y =>
                        {
                            var relatedItems = tmpData.Select(z => z.ProizvodId).Where(z => z != y);

                            foreach (var z in relatedItems)
                            {
                                data.Add(new ProizvodRecommendation
                                {
                                    ProizvodId = (uint)y,
                                    CoProizvodId = (uint)z
                                });
                            }
                        });
                    }

                    var trainData = _mlContext.Data.LoadFromEnumerable(data);

                    MatrixFactorizationTrainer.Options options = new MatrixFactorizationTrainer.Options();
                    options.MatrixColumnIndexColumnName = nameof(ProizvodRecommendation.ProizvodId);
                    options.MatrixRowIndexColumnName = nameof(ProizvodRecommendation.CoProizvodId);
                    options.LabelColumnName = "Label";

                    options.LossFunction = MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass;
                    options.Alpha = 0.01;
                    options.Lambda = 0.025;

                    options.NumberOfIterations = 100;
                    options.C = 0.00001;

                    var est = _mlContext.Recommendation().Trainers.MatrixFactorization(options);

                    _model = est.Fit(trainData);
                }
            }

            var proizvodi = _dbContext.Proizvods.Where(x => x.ProizvodId != proizvodId).ToList();

            var predictionResult = new List<Tuple<Database.Proizvod, float>>();

            foreach (var proizvod in proizvodi)
            {
                var predictionEngine = _mlContext.Model.CreatePredictionEngine<ProizvodRecommendation, CoProizvodPrediction>(_model);

                var prediction = predictionEngine.Predict(new ProizvodRecommendation
                {
                    ProizvodId = (uint)proizvodId,
                    CoProizvodId = (uint)proizvod.ProizvodId
                });

                predictionResult.Add(new Tuple<Database.Proizvod, float>(proizvod, prediction.Score));
            }

            var finalResult = predictionResult.OrderByDescending(x => x.Item2).Select(x => x.Item1).Take(3).ToList();

            return _mapper.Map<List<Database.Proizvod>>(finalResult); 
        }

        public async Task<PagedResult<Database.Recommender>> TrainModelAsync(CancellationToken cancellationToken)
        {
            try
            {
                var proizvodi = await _dbContext.Proizvods.ToListAsync(cancellationToken);


                // Bilo > 1 pa radilo
                if (proizvodi.Count > 4)
                {
                    var recommendList = new List<Database.Recommender>();

                    foreach (var proizvod in proizvodi)
                    {
                        var recommendedProizvodi = Recommend(proizvod.ProizvodId);

                        var result = new Database.Recommender
                        {
                            ProizvodId = proizvod.ProizvodId,
                            PrvaPreporukaId = recommendedProizvodi[0].ProizvodId,
                            DrugaPreporukaId = recommendedProizvodi[1].ProizvodId,
                            TrecaPreporukaId = recommendedProizvodi[2].ProizvodId,
                        };

                        recommendList.Add(result);
                    }

                    await CreateNewRecommendation(recommendList, cancellationToken);
                    await _dbContext.SaveChangesAsync(cancellationToken);

                    return _mapper.Map<PagedResult<Database.Recommender>>(recommendList);

                }
                else
                {
                    throw new Exception("Not enough data to generate recommendations.");

                }
            }
            catch (Exception ex)
            {
                var o = ex;
                throw;
            }

        }

        private async Task CreateNewRecommendation(List<Database.Recommender> results, CancellationToken cancellationToken)
        {
            var existingRecommendations = await _dbContext.Recommenders.ToListAsync(cancellationToken);
            var proizvodiCount = await _dbContext.Proizvods.CountAsync(cancellationToken);
            var recommendationCount = await _dbContext.Recommenders.CountAsync(cancellationToken);

            if (recommendationCount != 0)
            {
                if (recommendationCount > proizvodiCount)
                {
                    for (int i = 0; i < proizvodiCount; i++)
                    {
                        existingRecommendations[i].ProizvodId = results[i].ProizvodId;
                        existingRecommendations[i].PrvaPreporukaId = results[i].PrvaPreporukaId;
                        existingRecommendations[i].DrugaPreporukaId = results[i].DrugaPreporukaId;
                        existingRecommendations[i].TrecaPreporukaId = results[i].TrecaPreporukaId;
                    }
                    for (int i = 0; i < recommendationCount; i++)
                    {
                        _dbContext.Recommenders.Remove(existingRecommendations[i]);
                    }
                }
                else
                {
                    for (int i = 0; i < recommendationCount; i++)
                    {
                        existingRecommendations[i].ProizvodId = results[i].ProizvodId;
                        existingRecommendations[i].PrvaPreporukaId = results[i].PrvaPreporukaId;
                        existingRecommendations[i].DrugaPreporukaId = results[i].DrugaPreporukaId;
                        existingRecommendations[i].TrecaPreporukaId = results[i].TrecaPreporukaId;
                    }

                    var num = results.Count - recommendationCount;

                    if (num > 0)
                    {
                        for (int i = results.Count - num; i < results.Count; i++)
                        {
                            await _dbContext.Recommenders.AddAsync(results[i], cancellationToken);
                        }
                    }
                }
            }
            else
            {
                await _dbContext.Recommenders.AddRangeAsync(results, cancellationToken);
            }
        }

    }
}
