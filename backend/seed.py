import asyncio
import logging
from sqlalchemy import select, delete
from app.database import AsyncSessionLocal, init_db
from app.models.plant import Plant

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

CURATED_NATIVE_PLANTS = [
    {
        "scientific_name": "Bougainvillea glabra",
        "common_name": "Bougainvillea / Paper Flower",
        "family": "Nyctaginaceae",
        "native_region": "South America",
        "conservation_status": "Least Concern",
        "ecological_importance": "Provides dense sheltering habitat; acts as a nectar source for local butterflies and birds.",
        "description": "A vigorous climbing or sprawling woody shrub renowned for its profuse clusters of brightly colored papery bracts surrounding small creamy-white flowers.",
        "threats": "Excessive artificial waterlogging, severe frost in colder microclimates, and hard indiscriminate pruning during budding periods.",
        "conservation_actions": "Maintain well-drained soil, prune judiciously after major bloom cycles, and preserve perimeter bio-fence plantings as wildlife stepping stones.",
        "habitat": "Tropical and subtropical gardens, campus perimeter bio-fences, sun-drenched pergolas, and stone courtyard walls.",
        "identification_features": "Curved sharp thorns along woody stems, vibrant magenta-purple papery bracts containing trios of tiny tubular creamy florets, smooth ovate green leaves.",
        "image_url": "https://images.unsplash.com/photo-1596726919245-cfa488b0304a?w=800",
        "plantnet_species_name": "Bougainvillea glabra Choisy"
    },
    {
        "scientific_name": "Bambusa vulgaris",
        "common_name": "Common Bamboo",
        "family": "Poaceae",
        "native_region": "Southern Asia",
        "conservation_status": "Not Evaluated",
        "ecological_importance": "Excellent for rapid carbon sequestration, soil erosion control, and water regulation.",
        "description": "Fast-growing clumping bamboo forming dense tall woody culms, highly valued for ecological restoration, sustainable green material, and cooling campus microclimates.",
        "threats": "Gregarious monocarpic flowering cycles followed by dieback, uncontrolled clearing along stream banks, and fungal culm rot.",
        "conservation_actions": "Regular culm thinning and clump maintenance, planting along riparian buffer zones to prevent slope runoff and riverbank erosion.",
        "habitat": "Moist riverbanks, campus green belts, retention pond borders, and tropical valley corridors.",
        "identification_features": "Erect woody hollow stems (culms) with distinct nodes and ringed internodes, linear lanceolate leaves with rough margins, clumping root architecture.",
        "image_url": "https://images.unsplash.com/photo-1547517023-7ca0c162f816?w=800",
        "plantnet_species_name": "Bambusa vulgaris Schrad. ex J.C.Wendl."
    },
    {
        "scientific_name": "Tecoma stans",
        "common_name": "Yellow Bells / Yellow Trumpetbush",
        "family": "Bignoniaceae",
        "native_region": "The Americas",
        "conservation_status": "Least Concern",
        "ecological_importance": "Highly attractive to pollinators; thrives in Tamil Nadu's heat.",
        "description": "Fast-growing semi-evergreen shrub or small tree celebrated for its showy hanging clusters of bright canary-yellow bell-and-trumpet-shaped blossoms.",
        "threats": "Can spread aggressively into unmanaged open ground if seeds disperse unchecked; susceptible to powdery mildew in high humidity.",
        "conservation_actions": "Incorporate in campus pollinator sanctuaries, trim mature seed pods to encourage continuous flowering, and utilize for drought-tolerant landscaping.",
        "habitat": "Sunny gardens, institutional courtyards, roadsides, and dry tropical landscape grounds.",
        "identification_features": "Bright yellow tubular trumpet-shaped flowers with faint reddish lines in the throat, serrated pinnate green leaves, long narrow pendant bean-like capsules.",
        "image_url": "https://images.unsplash.com/photo-1622383563227-04401ab4e5ea?w=800",
        "plantnet_species_name": "Tecoma stans (L.) Juss. ex Kunth"
    },
    {
        "scientific_name": "Chrysanthemum × morifolium",
        "common_name": "Florist's Chrysanthemum",
        "family": "Asteraceae",
        "native_region": "Asia (Originating in China)",
        "conservation_status": "Not Evaluated (Cultivar)",
        "ecological_importance": "Provides late-season nectar for beneficial insects, though heavily hybridized varieties yield less pollen.",
        "description": "Beloved perennial flowering plant cultivated globally for its vast diversity of vibrant inflorescences, providing crucial late-season sustenance for garden pollinators.",
        "threats": "Aphid infestations, fungal leaf spots from overhead watering, and root rot in heavy waterlogged beds.",
        "conservation_actions": "Cultivate open-centered varieties that facilitate easy pollinator foraging, practice organic pest management, and propagate through root divisions.",
        "habitat": "Ornamental campus borders, conservatory greenhouses, student flower beds, and balcony containers.",
        "identification_features": "Deeply lobed aromatic grayish-green leaves, composite daisy-like flower heads with dense concentric circles of ray florets in rich autumnal shades.",
        "image_url": "https://images.unsplash.com/photo-1508615039623-a25605d2b022?w=800",
        "plantnet_species_name": "Chrysanthemum × morifolium Ramat."
    },
    {
        "scientific_name": "Helianthus annuus",
        "common_name": "Common Sunflower",
        "family": "Asteraceae",
        "native_region": "North America",
        "conservation_status": "Least Concern",
        "ecological_importance": "Produces high-value forage (seeds and nectar) for a wide variety of birds, bees, and insects.",
        "description": "Iconic tall annual herb celebrated for its majestic golden flower heads that track the path of the sun (heliotropism) during young growth stages.",
        "threats": "Seed predation by parakeets and rodents before maturity, snail and slug damage to young seedlings, stem-borer caterpillars.",
        "conservation_actions": "Integrate into campus biodiversity patches, allow flower heads to dry naturally in winter to feed overwintering songbirds.",
        "habitat": "Sunny garden plots, campus demonstration farms, open pollinator fields, and meadow edges.",
        "identification_features": "Tall stout coarse hairy stem, large broad triangular-cordate rough leaves, massive circular composite flower head with yellow rays and dark center.",
        "image_url": "https://images.unsplash.com/photo-1597848212624-a19eb35e2651?w=800",
        "plantnet_species_name": "Helianthus annuus L."
    },
    {
        "scientific_name": "Roystonea regia",
        "common_name": "Cuban Royal Palm",
        "family": "Arecaceae",
        "native_region": "Caribbean, Mexico & Florida",
        "conservation_status": "Least Concern",
        "ecological_importance": "The crown acts as a nesting site for birds and bats; a classic avenue tree in Indian institutions.",
        "description": "Stately and majestic palm known for its columnar smooth greyish-white trunk resembling polished concrete, crowned by an elegant spray of deep green pinnate fronds.",
        "threats": "Lethal bronzing phytoplasma diseases, mechanical trunk gouges from lawnmowers and construction, lightning strikes to elevated crowns.",
        "conservation_actions": "Periodic canopy safety audits, preserving mature avenue rows as high-canopy aerial wildlife nesting corridors across institutional campuses.",
        "habitat": "Grand campus entrance avenues, botanical gardens, civic ceremonial pathways, and tropical parks.",
        "identification_features": "Smooth swollen grayish-white trunk with ringed leaf scars, prominent vivid green crownshaft, 10–15 foot long gracefully arching feathery fronds.",
        "image_url": "https://images.unsplash.com/photo-1513836279014-a89f7a76ae86?w=800",
        "plantnet_species_name": "Roystonea regia (Kunth) O.F.Cook"
    },
    {
        "scientific_name": "Cordyline fruticosa",
        "common_name": "Ti Plant / Cabbage Palm",
        "family": "Asparagaceae",
        "native_region": "Southeast Asia & Oceania",
        "conservation_status": "Least Concern",
        "ecological_importance": "Provides microhabitats and ground-level shelter for small garden fauna and insects.",
        "description": "Evergreen tropical foliage plant prized for its architectural palm-like tufts of glossy, boldly colored lanceolate leaves ranging from bright lime to deep burgundy-pink.",
        "threats": "Spider mites in dry conditions, leaf tip burn from fluoridated irrigation water, stem rot in waterlogged dense clay soils.",
        "conservation_actions": "Utilize in multi-tiered understory garden beds to shade the soil, maintain organic leaf mulch layers to shelter beneficial ground microfauna.",
        "habitat": "Tropical garden borders, shaded courtyard beds, campus rockeries, and indoor atriums.",
        "identification_features": "Narrow lanceolate leathery leaves growing spirally along a slender cane-like woody stem, foliage flushed with rich reddish-bronze and magenta tints.",
        "image_url": "https://images.unsplash.com/photo-1614594975525-e45190c55d0b?w=800",
        "plantnet_species_name": "Cordyline fruticosa (L.) A.Chev."
    },
    {
        "scientific_name": "Tabernaemontana divaricata",
        "common_name": "Crape Jasmine / Nandiyavattai",
        "family": "Apocynaceae",
        "native_region": "South & Southeast Asia",
        "conservation_status": "Least Concern",
        "ecological_importance": "Often grown as a structural hedge; its fragrant flowers serve as a nectar source for moths.",
        "description": "Hardy evergreen shrub with glossy deep green foliage and pristine pure white pinwheel-shaped blossoms that exude a delicate evening fragrance.",
        "threats": "Caterpillar defoliation by oleander hawk moth larvae, sooty mold associated with scale insect secretions.",
        "conservation_actions": "Maintained as eco-hedges to filter particulate dust, avoid broad-spectrum chemical sprays to protect nocturnal pollinating moths.",
        "habitat": "Campus pathway hedges, traditional medicinal gardens, temple borders, and residential complexes.",
        "identification_features": "Glossy dark green elliptic leaves yielding milky latex sap when broken, waxy snow-white flowers with 5 ruffled petals arranged like a windmill.",
        "image_url": "https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=800",
        "plantnet_species_name": "Tabernaemontana divaricata (L.) R.Br. ex Roem. & Schult."
    },
    {
        "scientific_name": "Samanea saman",
        "common_name": "Rain Tree / Thoongu Moonji Maram",
        "family": "Fabaceae",
        "native_region": "Central & South America",
        "conservation_status": "Least Concern",
        "ecological_importance": "A nitrogen-fixing tree that improves soil quality and provides massive canopy shelter against the hot sun.",
        "description": "Magnificent giant shade tree with a sprawling umbrella-like canopy whose leaflets fold together at dusk and before rains, cooling ambient temperatures substantially.",
        "threats": "Windthrow if shallow root systems are suffocated by asphalt or concrete paving, stem borers in mature unmaintained trees.",
        "conservation_actions": "Preserve unpaved root buffer zones around heritage campus trees, perform routine arboricultural canopy checks, and value as key urban heat mitigation anchors.",
        "habitat": "Campus heritage quadrangles, broad central avenues, parklands, and institutional campuses across tropical India.",
        "identification_features": "Massive spreading symmetrical canopy, bipinnate leaves with leaflets that sleep/fold at sunset, showy pink and white puffball flower clusters.",
        "image_url": "https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800",
        "plantnet_species_name": "Samanea saman (Jacq.) Merr."
    },
    {
        "scientific_name": "Cordyline fruticosa",
        "common_name": "Ti Plant (Tall grouping)",
        "family": "Asparagaceae",
        "native_region": "Southeast Asia & Oceania",
        "conservation_status": "Least Concern",
        "ecological_importance": "Mature groupings stabilize soil and create shaded, humid microclimates for smaller organisms.",
        "description": "Mature architectural groupings of multi-stemmed Ti Plants forming tall multi-layered groves that act as windbreaks, slope anchors, and microclimate regulators.",
        "threats": "Soil erosion during torrential monsoon downpours before root systems interlock, mechanical damage during groundskeeping mowing.",
        "conservation_actions": "Group plantings along sloped terrain for bio-stabilization, preserve leaf litter mulch below the cluster to support beneficial earthworms and ground organisms.",
        "habitat": "Campus border clusters, shaded slopes, botanical accent groupings, and moisture retention zones.",
        "identification_features": "Clustered tall woody canes exceeding 2.5–3 meters in height, dense crown tufts of deep bronze-green and burgundy leaves, dense fibrous network of stabilizing roots.",
        "image_url": "https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?w=800",
        "plantnet_species_name": "Cordyline fruticosa (L.) A.Chev."
    },
    {
        "scientific_name": "Pandanus veitchii",
        "common_name": "Variegated Screw Pine / Dwarf Pandanus",
        "family": "Pandanaceae",
        "native_region": "Polynesia / Pacific Islands",
        "conservation_status": "Least Concern",
        "ecological_importance": "Highly heat and drought-resistant; acts as an excellent soil stabilizer in arid tropical landscapes.",
        "description": "Striking architectural palm-like shrub featuring spiraling rosettes of long, sword-like leaves vividly striped with creamy-white and green, elevated by aerial prop roots.",
        "threats": "Basal rot in waterlogged un-drained clay depressions, leaf tip necrosis if exposed to prolonged desiccating dry winds without occasional moisture.",
        "conservation_actions": "Plant on elevated berms and rockeries for natural soil retention, protect aerial stilt roots from weed-trimmers and physical damage.",
        "habitat": "Arid landscape features, campus rockeries, raised coastal garden beds, and tropical sun courtyards.",
        "identification_features": "Spirally arranged arching strap-like leaves with sharp marginal spines and prominent creamy-white longitudinal stripes, thick prop/stilt roots supporting stem base.",
        "image_url": "https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?w=800",
        "plantnet_species_name": "Pandanus veitchii Mast."
    }
]


async def seed_database():
    logger.info("Re-initializing database tables...")
    from app.database import engine, Base
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
        await conn.run_sync(Base.metadata.create_all)

    async with AsyncSessionLocal() as session:
        logger.info(f"Seeding {len(CURATED_NATIVE_PLANTS)} curated plant species...")
        for plant_data in CURATED_NATIVE_PLANTS:
            plant = Plant(**plant_data)
            session.add(plant)

        await session.commit()
        result = await session.execute(select(Plant))
        seeded_plants = result.scalars().all()
        logger.info(f"Database seeding completed successfully! Total plants in DB: {len(seeded_plants)}")


if __name__ == "__main__":
    asyncio.run(seed_database())
