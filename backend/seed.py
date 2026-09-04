import asyncio
import logging
from sqlalchemy import select
from app.database import AsyncSessionLocal, init_db
from app.models.plant import Plant

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

CURATED_NATIVE_PLANTS = [
    {
        "scientific_name": "Ficus benghalensis",
        "common_name": "Banyan Tree",
        "family": "Moraceae",
        "native_region": "Indian Subcontinent",
        "conservation_status": "Least Concern",
        "ecological_importance": "Keystone species providing critical shelter, roosting canopy, and year-round fruit for hundreds of bird, mammal, and insect species.",
        "description": "The national tree of India, famous for its massive canopy supported by pillar-like aerial prop roots that anchor deep into the soil.",
        "threats": "Urban construction, root damage from road paving, and fragmentation of ancient groves.",
        "conservation_actions": "Protection of heritage specimen trees, inclusion in urban canopy restoration programs, and temple grove preservation.",
        "habitat": "Tropical and subtropical dry deciduous forests, plains, and sacred groves across India.",
        "identification_features": "Large leathery glossy ovate leaves with prominent light veins, thick aerial prop roots, reddish-orange paired figs.",
        "image_url": "https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800",
        "plantnet_species_name": "Ficus benghalensis L."
    },
    {
        "scientific_name": "Azadirachta indica",
        "common_name": "Neem",
        "family": "Meliaceae",
        "native_region": "Indian Subcontinent",
        "conservation_status": "Least Concern",
        "ecological_importance": "Natural organic pest repellent source, enhances soil microbial health, heavy carbon sequestrator, and air purifier.",
        "description": "Fast-growing evergreen tree revered for over 4,000 years in traditional Indian medicine (Ayurveda) and organic agriculture.",
        "threats": "Fungal blights, over-harvesting of bark, and industrial pollution.",
        "conservation_actions": "Promoting community afforestation, sustainable seed harvesting, and agroforestry planting.",
        "habitat": "Dry tropical forests, arid river valleys, roadside belts, and homestead gardens.",
        "identification_features": "Pinnately compound leaves with serrated asymmetrical leaflets, small fragrant white honey-scented flowers, smooth yellow oval drupes.",
        "image_url": "https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=800",
        "plantnet_species_name": "Azadirachta indica A.Juss."
    },
    {
        "scientific_name": "Syzygium cumini",
        "common_name": "Jamun / Black Plum",
        "family": "Myrtaceae",
        "native_region": "Indian Subcontinent",
        "conservation_status": "Least Concern",
        "ecological_importance": "Essential monsoon food source for fruit bats, wild birds, and mammals; vital for riparian riverbank stabilization.",
        "description": "Large evergreen tree bearing dark purple juicy berries renowned in India for culinary and antidiabetic medicinal uses.",
        "threats": "Encroachment of wetland and riverbank habitats, groundwater depletion.",
        "conservation_actions": "Riparian buffer zone restoration and community fruit forest planting.",
        "habitat": "Moist tropical forests, river valleys, and alluvial plains across India.",
        "identification_features": "Opposite smooth dark green oblong leaves emitting a pleasant turpentine scent when crushed, sweet dark purple oblong berries.",
        "image_url": "https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=800",
        "plantnet_species_name": "Syzygium cumini (L.) Skeels"
    },
    {
        "scientific_name": "Ficus religiosa",
        "common_name": "Sacred Fig / Peepal",
        "family": "Moraceae",
        "native_region": "Indian Subcontinent",
        "conservation_status": "Least Concern",
        "ecological_importance": "High daytime oxygen producer; supports an obligate fig-wasp mutualistic pollination ecosystem.",
        "description": "Sacred dry-season deciduous tree instantly recognized by its elegant heart-shaped leaves ending in a distinctive extended tail tip.",
        "threats": "Damage during urban wall clearings and heavy urban construction.",
        "conservation_actions": "Conservation in biodiversity parks, heritage tree mapping, and temple forest protection.",
        "habitat": "Sub-Himalayan tracts, deciduous forests, and urban environments across India.",
        "identification_features": "Heart-shaped cordate leaves with a long linear drip tip, smooth light grey bark, dark purple small figs.",
        "image_url": "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800",
        "plantnet_species_name": "Ficus religiosa L."
    },
    {
        "scientific_name": "Terminalia elliptica",
        "common_name": "Indian Laurel / Asana",
        "family": "Combretaceae",
        "native_region": "Peninsular & Central India",
        "conservation_status": "Least Concern",
        "ecological_importance": "Stores reservoir water in its trunk during dry seasons, vital dry-forest sanctuary for wildlife.",
        "description": "Large deciduous timber tree famous for its distinctive crocodile-skin patterned bark and natural water storage capacity.",
        "threats": "Illegal timber felling and frequent forest fires.",
        "conservation_actions": "Forest department fire-line management and protected reserve monitoring.",
        "habitat": "Dry and moist deciduous forests of Central India and the Deccan Plateau.",
        "identification_features": "Deeply fissured dark grey bark resembling crocodile hide, sub-opposite oblong leaves, 5-winged woody fruits.",
        "image_url": "https://images.unsplash.com/photo-1511497584788-8767611136f6?w=800",
        "plantnet_species_name": "Terminalia elliptica Willd."
    },
    {
        "scientific_name": "Saraca asoca",
        "common_name": "Ashoka Tree",
        "family": "Fabaceae",
        "native_region": "Western Ghats & Central India",
        "conservation_status": "Vulnerable",
        "ecological_importance": "Keystone understory rainforest tree supporting endemic butterfly species and nectar-feeding pollinators.",
        "description": "Beautiful rainforest tree producing heavy bunches of fragrant orange-scarlet flowers, deeply rooted in Indian cultural folklore.",
        "threats": "Destructive unsustainable bark stripping for pharmaceutical trade and Western Ghats habitat loss.",
        "conservation_actions": "Ex-situ propagation in botanical sanctuaries, legal enforcement against wild bark collection.",
        "habitat": "Moist evergreen forests, sacred groves, and stream edges in Western and Eastern Ghats.",
        "identification_features": "Paripinnate compound drooping leaves, dense globular flower clusters shifting from yellow-orange to bright crimson.",
        "image_url": "https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?w=800",
        "plantnet_species_name": "Saraca asoca (Roxb.) Willd."
    },
    {
        "scientific_name": "Madhuca longifolia",
        "common_name": "Mahua",
        "family": "Sapotaceae",
        "native_region": "Central & Peninsular India",
        "conservation_status": "Least Concern",
        "ecological_importance": "Core food security tree for indigenous tribal communities and forest wildlife (sloth bears, deer, birds).",
        "description": "Crucial deciduous forest tree producing sweet edible succulent floral corollas harvested extensively across rural India.",
        "threats": "Uncontrolled dry-season forest floor leaf fires lit during flower gathering.",
        "conservation_actions": "Fire-safe harvesting mesh nets provided to tribal collector cooperatives.",
        "habitat": "Dry deciduous forests of Madhya Pradesh, Chhattisgarh, Odisha, and Maharashtra.",
        "identification_features": "Fleshy pale cream-colored globose sweet flowers, thick leathery elliptic leaves clustered at branch tips.",
        "image_url": "https://images.unsplash.com/photo-1448375240586-882707db888b?w=800",
        "plantnet_species_name": "Madhuca longifolia (J.Koenig) J.F.Macbr."
    },
    {
        "scientific_name": "Aegle marmelos",
        "common_name": "Bael / Sacred Bilva",
        "family": "Rutaceae",
        "native_region": "Indian Subcontinent",
        "conservation_status": "Least Concern",
        "ecological_importance": "Host plant for the Common Mormon butterfly larval stage; highly drought-resistant dry ecosystem anchor.",
        "description": "Sacred thorny deciduous tree yielding hard-shelled aromatic medicinal fruits widely used for digestive health.",
        "threats": "Over-exploitation of wild fruit stock and agricultural land conversion.",
        "conservation_actions": "Cultivation in dryland agroforestry systems and temple biodiversity groves.",
        "habitat": "Dry deciduous forests, scrublands, and rocky hills across India.",
        "identification_features": "Trifoliate alternate leaves, sharp axillary spines, greenish-white sweet scented flowers, large woody yellow-green globose fruits.",
        "image_url": "https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=800",
        "plantnet_species_name": "Aegle marmelos (L.) Corrêa"
    },
    {
        "scientific_name": "Santalum album",
        "common_name": "Indian Sandalwood",
        "family": "Santalaceae",
        "native_region": "Peninsular India",
        "conservation_status": "Vulnerable",
        "ecological_importance": "Hemiparasitic root structure forming critical subterranean nutrient links with native host trees and shrubs.",
        "description": "World-famous aromatic heartwood tree endemic to Southern Peninsular India, producing prized sandalwood oil.",
        "threats": "Severe illegal logging/poaching, spike disease phytoplasma infection, and habitat fragmentation.",
        "conservation_actions": "RFID tree tagging, state forest protection squads, legal private sandalwood cultivation reforms.",
        "habitat": "Dry deciduous and scrub forests of Karnataka, Tamil Nadu, and Kerala.",
        "identification_features": "Opposite thin lanceolate leaves, tiny purplish-red unscented 4-valved flowers, small black fleshy drupes.",
        "image_url": "https://images.unsplash.com/photo-1544816155-12df9643f363?w=800",
        "plantnet_species_name": "Santalum album L."
    },
    {
        "scientific_name": "Butea monosperma",
        "common_name": "Flame of the Forest / Palash",
        "family": "Fabaceae",
        "native_region": "Indian Subcontinent",
        "conservation_status": "Least Concern",
        "ecological_importance": "Early dry-season nectar lifeline for sunbirds, drongos, and bees when forest water is scarce.",
        "description": "Stunning deciduous tree known as Palash or Tesu, whose bright orange-red blooms light up dry landscapes during early spring.",
        "threats": "Sub-urban clearing and loss of traditional wasteland habitats.",
        "conservation_actions": "Landscape restoration planting on degraded soils and saline lands.",
        "habitat": "Plains, dry deciduous tracts, open woodlands, and degraded rangelands.",
        "identification_features": "Trifoliate tough broad leaves, brilliant flame-orange parrot-beak shaped flowers, velvety flat pod fruits.",
        "image_url": "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=800",
        "plantnet_species_name": "Butea monosperma (Lam.) Taub."
    },
    {
        "scientific_name": "Pongamia pinnata",
        "common_name": "Karanja / Indian Beech",
        "family": "Fabaceae",
        "native_region": "Indian Subcontinent",
        "conservation_status": "Least Concern",
        "ecological_importance": "Nitrogen-fixing leguminous tree; excellent soil erosion barrier along riverbanks and coastal zones.",
        "description": "Hardy fast-growing native tree yielding oil-rich seeds utilized for bio-diesel production and organic soil enrichment.",
        "threats": "Industrial estate encroachment into coastal and river plain habitats.",
        "conservation_actions": "Widespread planting in urban heat-island mitigation corridors and bio-energy plantations.",
        "habitat": "Riverbanks, coastal strips, mangrove margins, and urban avenue roadsides.",
        "identification_features": "Shiny dark green pinnate leaves, drooping racemes of pinkish-white pea flowers, thick woody smooth seed pods.",
        "image_url": "https://images.unsplash.com/photo-1502082553048-f009c37129b9?w=800",
        "plantnet_species_name": "Pongamia pinnata (L.) Pierre"
    },
    {
        "scientific_name": "Alstonia scholaris",
        "common_name": "Saptaparni / Devil Tree",
        "family": "Apocynaceae",
        "native_region": "Indian Subcontinent",
        "conservation_status": "Least Concern",
        "ecological_importance": "Urban microclimate cooler and heavy particulate dust absorber with dense evergreen canopy architecture.",
        "description": "Tall elegant evergreen tree featuring leaves arranged in characteristic whorls of 7 ('Sapta' + 'Parni').",
        "threats": "Severe pruning during urban power line clearances.",
        "conservation_actions": "Integration into green city masterplans and institutional campus landscapes.",
        "habitat": "Moist rainforests, sub-Himalayan valleys, and urban parks across India.",
        "identification_features": "Whorls of 7 glossy oblanceolate leaves, strongly fragrant cream-green tiny flowers, long twin pendulous follicle pods.",
        "image_url": "https://images.unsplash.com/photo-1513836279014-a89f7a76ae86?w=800",
        "plantnet_species_name": "Alstonia scholaris (L.) R.Br."
    },
    {
        "scientific_name": "Vanda coerulea",
        "common_name": "Orchid",
        "family": "Orchidaceae",
        "native_region": "Western Ghats & North-East India",
        "conservation_status": "Vulnerable",
        "ecological_importance": "Iconic epiphyte species supporting specialized orchid bee and moth pollinators in tropical humid forest canopies.",
        "description": "Elegant epiphytic orchid famous for its striking blue, pink, and multi-patterned blooms with dense tessellated petals.",
        "threats": "Over-collection for wild horticulture, forest canopy loss.",
        "conservation_actions": "Protection under CITES Appendix II, orchid sanctuary preservation in native mountain ranges.",
        "habitat": "Humid subtropical mountain forests and tropical evergreen canopies.",
        "identification_features": "Dense pom-pom or starburst floral clusters, curved linear petals, distinctive labellum lip, epiphytic roots.",
        "image_url": "https://images.unsplash.com/photo-1525310072745-f49212b5ac6d?w=800",
        "plantnet_species_name": "Vanda coerulea Griff. ex Lindl."
    },
    {
        "scientific_name": "Passiflora incarnata",
        "common_name": "Passion flower / Krishna Kamal",
        "family": "Passifloraceae",
        "native_region": "Pan-India & Western Ghats",
        "conservation_status": "Least Concern",
        "ecological_importance": "Crucial host plant for native Heliconiinae butterflies and carpenter bee pollinators across tropical ecosystems.",
        "description": "Exotic native climbing vine famous for its intricate corona of purple and white filaments surrounding prominent radial stamens.",
        "threats": "Habitat clearance and pesticide spraying on wild hedges.",
        "conservation_actions": "Promoting native vine greening in gardens and biodiversity corridors.",
        "habitat": "Thickets, riverbanks, forest edges, and traditional home gardens across India.",
        "identification_features": "Intricate radial purple/white corona filaments, 5 pale pink/purple sepals and petals, 3-lobed leaves, central prominent styles.",
        "image_url": "https://images.unsplash.com/photo-1596727147705-61a532a659bd?w=800",
        "plantnet_species_name": "Passiflora incarnata L."
    }
]


async def seed_database():
    logger.info("Initializing database tables...")
    await init_db()

    async with AsyncSessionLocal() as session:
        result = await session.execute(select(Plant))
        existing_plants = result.scalars().all()

        if existing_plants:
            logger.info(f"Database already contains {len(existing_plants)} plants. Skipping seed.")
            return

        logger.info(f"Seeding {len(CURATED_NATIVE_PLANTS)} curated native Indian plant species...")
        for plant_data in CURATED_NATIVE_PLANTS:
            plant = Plant(**plant_data)
            session.add(plant)

        await session.commit()
        logger.info("Database seeding completed successfully!")


if __name__ == "__main__":
    asyncio.run(seed_database())
