-- =========================
-- Core reference tables
-- =========================

CREATE TABLE countries (
                           id BIGINT AUTO_INCREMENT PRIMARY KEY,
                           name VARCHAR(150) NOT NULL UNIQUE,
                           official_name VARCHAR(200),
                           iso_alpha2 CHAR(2) UNIQUE,
                           iso_alpha3 CHAR(3) UNIQUE,
                           iso_numeric CHAR(3) UNIQUE,
                           phone_code VARCHAR(10),
                           currency_code VARCHAR(10),
                           capital VARCHAR(150),
                           region VARCHAR(100),
                           sub_region VARCHAR(100),
                           latitude DECIMAL(10,6),
                           longitude DECIMAL(10,6),
                           flag_image_url VARCHAR(500),
                           is_active BOOLEAN DEFAULT TRUE,
                           created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                           updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                               ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE user_status (
                             id BIGINT AUTO_INCREMENT PRIMARY KEY,
                             status VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE user_roles (
                            id BIGINT AUTO_INCREMENT PRIMARY KEY,
                            role VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================
-- Users & institutions
-- =========================

CREATE TABLE institutions (
                              id BIGINT AUTO_INCREMENT PRIMARY KEY,
                              name VARCHAR(100) NOT NULL UNIQUE,
                              address VARCHAR(255),
                              city VARCHAR(100),
                              state VARCHAR(100),
                              country BIGINT,
                              zip_code VARCHAR(10),
                              phone VARCHAR(20),
                              email VARCHAR(100) UNIQUE,
                              website VARCHAR(255),
                              created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                              CONSTRAINT fk_institutions_country
                                  FOREIGN KEY (country) REFERENCES countries(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE users (
                       id BIGINT AUTO_INCREMENT PRIMARY KEY,
                       first_name VARCHAR(100) NOT NULL,
                       last_name VARCHAR(100) NOT NULL,
                       email VARCHAR(100) NOT NULL UNIQUE,
                       password VARCHAR(255) NOT NULL,
                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                       updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                           ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE user_has_roles (
                                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                user_id BIGINT NOT NULL,
                                role_id BIGINT NOT NULL,
                                CONSTRAINT fk_uhr_user
                                    FOREIGN KEY (user_id) REFERENCES users(id),
                                CONSTRAINT fk_uhr_role
                                    FOREIGN KEY (role_id) REFERENCES user_roles(id),
                                UNIQUE (user_id, role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE user_has_institutions (
   id BIGINT AUTO_INCREMENT PRIMARY KEY,
   user_id BIGINT NOT NULL,
   institution_id BIGINT NOT NULL,
   joined_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
   graduation_year INT,
   is_active BOOLEAN DEFAULT TRUE,
   is_academic_staff BOOLEAN DEFAULT FALSE,
   university_email VARCHAR(100),
   is_email_verified BOOLEAN DEFAULT FALSE,
   designation VARCHAR(100),
   CONSTRAINT fk_uhi_user
       FOREIGN KEY (user_id) REFERENCES users(id),
   CONSTRAINT fk_uhi_institution
       FOREIGN KEY (institution_id) REFERENCES institutions(id),
   UNIQUE (user_id, institution_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_uhi_user_id ON user_has_institutions(user_id);
CREATE INDEX idx_uhi_institution_id ON user_has_institutions(institution_id);


-- =========================
-- Trees & biodiversity
-- =========================

CREATE TABLE trees (
                       id BIGINT AUTO_INCREMENT PRIMARY KEY,
                       scientific_name VARCHAR(255) NOT NULL,
                       common_name VARCHAR(255),
                       family VARCHAR(255),
                       genus VARCHAR(255),
                       description TEXT,
                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                       updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                           ON UPDATE CURRENT_TIMESTAMP,
                       INDEX idx_scientific_name (scientific_name),
                       INDEX idx_genus_family (genus, family)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE tree_other_names (
                                  id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                  tree_id BIGINT NOT NULL,
                                  language VARCHAR(50),
                                  country_id BIGINT,
                                  name VARCHAR(255),
                                  CONSTRAINT fk_ton_tree
                                      FOREIGN KEY (tree_id) REFERENCES trees(id),
                                  CONSTRAINT fk_ton_country
                                      FOREIGN KEY (country_id) REFERENCES countries(id),
                                  INDEX idx_ton_tree (tree_id),
                                  INDEX idx_ton_country (country_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE tree_geo_availability (
                                       id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                       tree_id BIGINT NOT NULL,
                                       country VARCHAR(50),
                                       region VARCHAR(100),
                                       latitude DECIMAL(9,6),
                                       longitude DECIMAL(9,6),
                                       altitude DECIMAL(9,6),
                                       CONSTRAINT fk_tga_tree
                                           FOREIGN KEY (tree_id) REFERENCES trees(id),
                                       INDEX idx_tga_tree (tree_id),
                                       INDEX idx_tga_location (country, region)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================
-- Red Data Book
-- =========================

CREATE TABLE red_databook_status (
                                     id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                     category_code VARCHAR(10) NOT NULL UNIQUE,
                                     category_name VARCHAR(100) NOT NULL,
                                     colour_code VARCHAR(20),
                                     description TEXT,
                                     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE red_databook_tree_details (
                                           id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                           tree_id BIGINT NOT NULL,
                                           status_id BIGINT NOT NULL,
                                           population VARCHAR(100),
                                           country_id BIGINT NOT NULL,
                                           taxon_id INT,
                                           version VARCHAR(50),
                                           book_issue VARCHAR(100),
                                           assessment_year INT,
                                           notes TEXT,
                                           added_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                           added_by VARCHAR(100),
                                           CONSTRAINT fk_rdt_tree
                                               FOREIGN KEY (tree_id) REFERENCES trees(id),
                                           CONSTRAINT fk_rdt_status
                                               FOREIGN KEY (status_id) REFERENCES red_databook_status(id),
                                           CONSTRAINT fk_rdt_country
                                               FOREIGN KEY (country_id) REFERENCES countries(id),
                                           UNIQUE (tree_id, book_issue, version),
                                           INDEX idx_rdt_tree (tree_id),
                                           INDEX idx_rdt_status (status_id),
                                           INDEX idx_rdt_country (country_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================
-- API & permissions
-- =========================

CREATE TABLE modules (
                         id BIGINT AUTO_INCREMENT PRIMARY KEY,
                         module_name VARCHAR(100) NOT NULL UNIQUE,
                         description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE api_keys (
                          id BIGINT AUTO_INCREMENT PRIMARY KEY,
                          user_name VARCHAR(100) NOT NULL,
                          api_key VARCHAR(255) NOT NULL UNIQUE,
                          max_modules INT DEFAULT 5,
                          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                          last_used TIMESTAMP,
                          INDEX idx_api_user (user_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE permission_modules (
                                    id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                    module_id BIGINT NOT NULL,
                                    is_enabled BOOLEAN DEFAULT TRUE,
                                    api_key_id BIGINT NOT NULL,
                                    CONSTRAINT fk_pm_api_key
                                        FOREIGN KEY (api_key_id) REFERENCES api_keys(id),
                                    CONSTRAINT fk_pm_module
                                        FOREIGN KEY (module_id) REFERENCES modules(id),
                                    UNIQUE (api_key_id, module_id),
                                    INDEX idx_pm_api_key (api_key_id),
                                    INDEX idx_pm_module (module_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================
-- Botanical Classification (Fully Normalized)
-- =========================

CREATE TABLE plant_kingdoms (
                                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE plant_divisions (
                                 id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                 kingdom_id BIGINT NOT NULL,
                                 name VARCHAR(100) NOT NULL,
                                 UNIQUE (kingdom_id, name),
                                 FOREIGN KEY (kingdom_id) REFERENCES plant_kingdoms(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE plant_classes (
                               id BIGINT AUTO_INCREMENT PRIMARY KEY,
                               division_id BIGINT NOT NULL,
                               name VARCHAR(100) NOT NULL,
                               UNIQUE (division_id, name),
                               FOREIGN KEY (division_id) REFERENCES plant_divisions(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE plant_orders (
                              id BIGINT AUTO_INCREMENT PRIMARY KEY,
                              class_id BIGINT NOT NULL,
                              name VARCHAR(100) NOT NULL,
                              UNIQUE (class_id, name),
                              FOREIGN KEY (class_id) REFERENCES plant_classes(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE plant_families (
                                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                order_id BIGINT NOT NULL,
                                name VARCHAR(100) NOT NULL,
                                UNIQUE (order_id, name),
                                FOREIGN KEY (order_id) REFERENCES plant_orders(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE plant_genera (
                              id BIGINT AUTO_INCREMENT PRIMARY KEY,
                              family_id BIGINT NOT NULL,
                              name VARCHAR(100) NOT NULL,
                              UNIQUE (family_id, name),
                              FOREIGN KEY (family_id) REFERENCES plant_families(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE plant_species (
                               id BIGINT AUTO_INCREMENT PRIMARY KEY,
                               genus_id BIGINT NOT NULL,
                               species_name VARCHAR(150) NOT NULL,
                               author VARCHAR(150),
                               UNIQUE (genus_id, species_name),
                               FOREIGN KEY (genus_id) REFERENCES plant_genera(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tree_botanical_details (
                                        id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                        tree_id BIGINT NOT NULL,
                                        species_id BIGINT NOT NULL,
                                        habit VARCHAR(100),
                                        leaf_type VARCHAR(100),
                                        leaf_arrangement VARCHAR(100),
                                        flower_description TEXT,
                                        fruit_description TEXT,
                                        bark_description TEXT,
                                        root_system VARCHAR(100),
                                        phenology TEXT,
                                        FOREIGN KEY (tree_id) REFERENCES trees(id),
                                        FOREIGN KEY (species_id) REFERENCES plant_species(id),
                                        UNIQUE (tree_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================
-- Genetic Data (Fully Normalized)
-- =========================

CREATE TABLE genetic_marker_types (
                                      id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                      name VARCHAR(100) NOT NULL UNIQUE,      -- DNA, RNA, Chloroplast, Mitochondrial
                                      description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE gene_loci (
                           id BIGINT AUTO_INCREMENT PRIMARY KEY,
                           locus_name VARCHAR(100) NOT NULL UNIQUE,
                           description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dna_sequences (
                               id BIGINT AUTO_INCREMENT PRIMARY KEY,
                               accession_number VARCHAR(100) NOT NULL UNIQUE,
                               marker_type_id BIGINT NOT NULL,
                               gene_locus_id BIGINT,
                               sequence TEXT NOT NULL,
                               sequence_length INT,
                               gc_content DECIMAL(5,2),
                               source_database VARCHAR(100),           -- GenBank, EMBL, DDBJ
                               FOREIGN KEY (marker_type_id) REFERENCES genetic_marker_types(id),
                               FOREIGN KEY (gene_locus_id) REFERENCES gene_loci(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tree_genetic_profiles (
                                       id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                       tree_id BIGINT NOT NULL,
                                       dna_sequence_id BIGINT NOT NULL,
                                       chromosome VARCHAR(50),
                                       is_reference BOOLEAN DEFAULT FALSE,
                                       notes TEXT,
                                       FOREIGN KEY (tree_id) REFERENCES trees(id),
                                       FOREIGN KEY (dna_sequence_id) REFERENCES dna_sequences(id),
                                       UNIQUE (tree_id, dna_sequence_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE population_genetics (
                                     id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                     tree_id BIGINT NOT NULL,
                                     country_id BIGINT,
                                     population_code VARCHAR(100),
                                     heterozygosity DECIMAL(5,4),
                                     allelic_richness DECIMAL(5,4),
                                     inbreeding_coefficient DECIMAL(5,4),
                                     sample_size INT,
                                     study_reference TEXT,
                                     FOREIGN KEY (tree_id) REFERENCES trees(id),
                                     FOREIGN KEY (country_id) REFERENCES countries(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- Ayurvedic / Traditional Medicine (Normalized)
-- =========================

CREATE TABLE ayurvedic_systems (
                                   id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                   system_name VARCHAR(100) NOT NULL UNIQUE,   -- Ayurveda, Siddha, Unani
                                   description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ayurvedic_properties (
                                      id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                      rasa VARCHAR(50),        -- Taste
                                      guna VARCHAR(50),        -- Quality
                                      virya VARCHAR(50),       -- Potency
                                      vipaka VARCHAR(50)       -- Post-digestive effect
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ayurvedic_uses (
                                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                disease_name VARCHAR(150) NOT NULL UNIQUE,
                                description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tree_ayurvedic_data (
                                     id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                     tree_id BIGINT NOT NULL,
                                     system_id BIGINT NOT NULL,
                                     properties_id BIGINT,
                                     plant_part_used VARCHAR(100),     -- Leaf, Bark, Root, Fruit
                                     preparation_method TEXT,          -- Decoction, Paste, Powder
                                     dosage TEXT,
                                     reference TEXT,
                                     FOREIGN KEY (tree_id) REFERENCES trees(id),
                                     FOREIGN KEY (system_id) REFERENCES ayurvedic_systems(id),
                                     FOREIGN KEY (properties_id) REFERENCES ayurvedic_properties(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tree_ayurvedic_use_map (
                                        tree_ayurvedic_id BIGINT NOT NULL,
                                        ayurvedic_use_id BIGINT NOT NULL,
                                        PRIMARY KEY (tree_ayurvedic_id, ayurvedic_use_id),
                                        FOREIGN KEY (tree_ayurvedic_id) REFERENCES tree_ayurvedic_data(id),
                                        FOREIGN KEY (ayurvedic_use_id) REFERENCES ayurvedic_uses(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================
-- Planting Instructions (Normalized)
-- =========================

CREATE TABLE soil_types (
                            id BIGINT AUTO_INCREMENT PRIMARY KEY,
                            soil_name VARCHAR(100) NOT NULL UNIQUE,   -- Sandy, Loamy, Clay
                            description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE climate_types (
                               id BIGINT AUTO_INCREMENT PRIMARY KEY,
                               climate_name VARCHAR(100) NOT NULL UNIQUE,  -- Tropical, Subtropical
                               description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE planting_methods (
                                  id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                  method_name VARCHAR(100) NOT NULL UNIQUE,   -- Seed, Cutting, Grafting
                                  description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tree_planting_instructions (
                                            id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                            tree_id BIGINT NOT NULL,
                                            planting_method_id BIGINT NOT NULL,
                                            soil_type_id BIGINT,
                                            climate_type_id BIGINT,
                                            spacing VARCHAR(50),
                                            watering_schedule TEXT,
                                            sunlight_requirement VARCHAR(100),
                                            best_season VARCHAR(100),
                                            germination_time VARCHAR(100),
                                            FOREIGN KEY (tree_id) REFERENCES trees(id),
                                            FOREIGN KEY (planting_method_id) REFERENCES planting_methods(id),
                                            FOREIGN KEY (soil_type_id) REFERENCES soil_types(id),
                                            FOREIGN KEY (climate_type_id) REFERENCES climate_types(id),
                                            UNIQUE (tree_id, planting_method_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================
-- Gardening Capability & Maintenance
-- =========================

CREATE TABLE maintenance_levels (
                                    id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                    level_name VARCHAR(50) NOT NULL UNIQUE,  -- Low, Medium, High
                                    description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE pruning_types (
                               id BIGINT AUTO_INCREMENT PRIMARY KEY,
                               pruning_name VARCHAR(100) NOT NULL UNIQUE,
                               description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tree_gardening_data (
                                     id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                     tree_id BIGINT NOT NULL,
                                     maintenance_level_id BIGINT,
                                     pruning_type_id BIGINT,
                                     growth_rate VARCHAR(50),        -- Slow, Moderate, Fast
                                     suitable_for_pots BOOLEAN DEFAULT FALSE,
                                     invasive BOOLEAN DEFAULT FALSE,
                                     lifespan_years INT,
                                     notes TEXT,
                                     FOREIGN KEY (tree_id) REFERENCES trees(id),
                                     FOREIGN KEY (maintenance_level_id) REFERENCES maintenance_levels(id),
                                     FOREIGN KEY (pruning_type_id) REFERENCES pruning_types(id),
                                     UNIQUE (tree_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================
-- Toxicity & Safety (Normalized)
-- =========================

CREATE TABLE toxicity_levels (
                                 id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                 level_name VARCHAR(50) NOT NULL UNIQUE,   -- Non-toxic, Mild, Severe, Fatal
                                 description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE affected_targets (
                                  id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                  target_name VARCHAR(100) NOT NULL UNIQUE  -- Humans, Pets, Livestock
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE toxicity_symptoms (
                                   id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                   symptom_name VARCHAR(150) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tree_toxicity_data (
                                    id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                    tree_id BIGINT NOT NULL,
                                    toxicity_level_id BIGINT NOT NULL,
                                    toxic_part VARCHAR(100),      -- Leaf, Seed, Bark
                                    exposure_method VARCHAR(100), -- Ingestion, Contact
                                    antidote TEXT,
                                    notes TEXT,
                                    FOREIGN KEY (tree_id) REFERENCES trees(id),
                                    FOREIGN KEY (toxicity_level_id) REFERENCES toxicity_levels(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tree_toxicity_targets (
                                       toxicity_id BIGINT NOT NULL,
                                       target_id BIGINT NOT NULL,
                                       PRIMARY KEY (toxicity_id, target_id),
                                       FOREIGN KEY (toxicity_id) REFERENCES tree_toxicity_data(id),
                                       FOREIGN KEY (target_id) REFERENCES affected_targets(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tree_toxicity_symptoms (
                                        toxicity_id BIGINT NOT NULL,
                                        symptom_id BIGINT NOT NULL,
                                        PRIMARY KEY (toxicity_id, symptom_id),
                                        FOREIGN KEY (toxicity_id) REFERENCES tree_toxicity_data(id),
                                        FOREIGN KEY (symptom_id) REFERENCES toxicity_symptoms(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- Languages Master
-- =========================

CREATE TABLE languages (
                           id BIGINT AUTO_INCREMENT PRIMARY KEY,
                           name VARCHAR(100) NOT NULL UNIQUE,     -- Sinhala, Tamil, English
                           iso_code CHAR(5) UNIQUE                -- si, ta, en
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================
-- Other Language / Local Names (Fully Normalized)
-- =========================

CREATE TABLE tree_local_names (
                                  id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                  tree_id BIGINT NOT NULL,
                                  country_id BIGINT NOT NULL,
                                  language_id BIGINT NOT NULL,
                                  local_name VARCHAR(255) NOT NULL,
                                  is_official BOOLEAN DEFAULT FALSE,
                                  notes TEXT,
                                  FOREIGN KEY (tree_id) REFERENCES trees(id),
                                  FOREIGN KEY (country_id) REFERENCES countries(id),
                                  FOREIGN KEY (language_id) REFERENCES languages(id),
                                  UNIQUE (tree_id, country_id, language_id, local_name),
                                  INDEX idx_tln_tree (tree_id),
                                  INDEX idx_tln_country (country_id),
                                  INDEX idx_tln_language (language_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================
-- Geographic Availability (Normalized)
-- =========================

CREATE TABLE availability_statuses (
                                       id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                       status_name VARCHAR(100) NOT NULL UNIQUE,   -- Native, Endemic, Introduced, Cultivated
                                       description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tree_geo_locations (
                                    id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                    tree_id BIGINT NOT NULL,
                                    country_id BIGINT NOT NULL,
                                    region VARCHAR(150),
                                    availability_status_id BIGINT NOT NULL,
                                    latitude DECIMAL(9,6),
                                    longitude DECIMAL(9,6),
                                    altitude_min DECIMAL(9,2),
                                    altitude_max DECIMAL(9,2),
                                    habitat_description TEXT,
                                    FOREIGN KEY (tree_id) REFERENCES trees(id),
                                    FOREIGN KEY (country_id) REFERENCES countries(id),
                                    FOREIGN KEY (availability_status_id) REFERENCES availability_statuses(id),
                                    UNIQUE (tree_id, country_id, region),
                                    INDEX idx_tgl_tree (tree_id),
                                    INDEX idx_tgl_country (country_id),
                                    INDEX idx_tgl_status (availability_status_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- OPTIONAL: countries (minimal seed set)
-- =========================
INSERT INTO countries (id, name, official_name, iso_alpha2, iso_alpha3, iso_numeric, phone_code, currency_code, capital, region, sub_region, latitude, longitude, flag_image_url) VALUES
                                                                                                                                                                                      (1,'Afghanistan','Islamic Republic of Afghanistan','AF','AFG','004','+93','AFN','Kabul','Asia','Southern Asia',33.9391,67.7100,'https://flagcdn.com/w320/af.png'),
                                                                                                                                                                                      (2,'Albania','Republic of Albania','AL','ALB','008','+355','ALL','Tirana','Europe','Southern Europe',41.1533,20.1683,'https://flagcdn.com/w320/al.png'),
                                                                                                                                                                                      (3,'Algeria','People''s Democratic Republic of Algeria','DZ','DZA','012','+213','DZD','Algiers','Africa','Northern Africa',28.0339,1.6596,'https://flagcdn.com/w320/dz.png'),
                                                                                                                                                                                      (4,'Andorra','Principality of Andorra','AD','AND','020','+376','EUR','Andorra la Vella','Europe','Southern Europe',42.5063,1.5218,'https://flagcdn.com/w320/ad.png'),
                                                                                                                                                                                      (5,'Angola','Republic of Angola','AO','AGO','024','+244','AOA','Luanda','Africa','Middle Africa',-11.2027,17.8739,'https://flagcdn.com/w320/ao.png'),
                                                                                                                                                                                      (6,'Antigua and Barbuda','Antigua and Barbuda','AG','ATG','028','+1-268','XCD','Saint John''s','North America','Caribbean',17.0608,-61.7964,'https://flagcdn.com/w320/ag.png'),
                                                                                                                                                                                      (7,'Argentina','Argentine Republic','AR','ARG','032','+54','ARS','Buenos Aires','South America','South America',-38.4161,-63.6167,'https://flagcdn.com/w320/ar.png'),
                                                                                                                                                                                      (8,'Armenia','Republic of Armenia','AM','ARM','051','+374','AMD','Yerevan','Asia','Western Asia',40.0691,45.0382,'https://flagcdn.com/w320/am.png'),
                                                                                                                                                                                      (9,'Australia','Commonwealth of Australia','AU','AUS','036','+61','AUD','Canberra','Oceania','Australia and New Zealand',-25.2744,133.7751,'https://flagcdn.com/w320/au.png'),
                                                                                                                                                                                      (10,'Austria','Republic of Austria','AT','AUT','040','+43','EUR','Vienna','Europe','Western Europe',47.5162,14.5501,'https://flagcdn.com/w320/at.png'),
                                                                                                                                                                                      (11,'Azerbaijan','Republic of Azerbaijan','AZ','AZE','031','+994','AZN','Baku','Asia','Western Asia',40.1431,47.5769,'https://flagcdn.com/w320/az.png'),
                                                                                                                                                                                      (12,'Bahamas','Commonwealth of The Bahamas','BS','BHS','044','+1-242','BSD','Nassau','North America','Caribbean',25.0343,-77.3963,'https://flagcdn.com/w320/bs.png'),
                                                                                                                                                                                      (13,'Bahrain','Kingdom of Bahrain','BH','BHR','048','+973','BHD','Manama','Asia','Western Asia',26.0667,50.5577,'https://flagcdn.com/w320/bh.png'),
                                                                                                                                                                                      (14,'Bangladesh','People''s Republic of Bangladesh','BD','BGD','050','+880','BDT','Dhaka','Asia','Southern Asia',23.6850,90.3563,'https://flagcdn.com/w320/bd.png'),
                                                                                                                                                                                      (15,'Barbados','Barbados','BB','BRB','052','+1-246','BBD','Bridgetown','North America','Caribbean',13.1939,-59.5432,'https://flagcdn.com/w320/bb.png'),
                                                                                                                                                                                      (16,'Belarus','Republic of Belarus','BY','BLR','112','+375','BYN','Minsk','Europe','Eastern Europe',53.7098,27.9534,'https://flagcdn.com/w320/by.png'),
                                                                                                                                                                                      (17,'Belgium','Kingdom of Belgium','BE','BEL','056','+32','EUR','Brussels','Europe','Western Europe',50.5039,4.4699,'https://flagcdn.com/w320/be.png'),
                                                                                                                                                                                      (18,'Belize','Belize','BZ','BLZ','084','+501','BZD','Belmopan','North America','Central America',17.1899,-88.4976,'https://flagcdn.com/w320/bz.png'),
                                                                                                                                                                                      (19,'Benin','Republic of Benin','BJ','BEN','204','+229','XOF','Porto-Novo','Africa','Western Africa',9.3077,2.3158,'https://flagcdn.com/w320/bj.png'),
                                                                                                                                                                                      (20,'Bhutan','Kingdom of Bhutan','BT','BTN','064','+975','BTN','Thimphu','Asia','Southern Asia',27.5142,90.4336,'https://flagcdn.com/w320/bt.png'),
                                                                                                                                                                                      (21,'Bolivia','Plurinational State of Bolivia','BO','BOL','068','+591','BOB','Sucre','South America','South America',-16.2902,-63.5887,'https://flagcdn.com/w320/bo.png'),
                                                                                                                                                                                      (22,'Bosnia and Herzegovina','Bosnia and Herzegovina','BA','BIH','070','+387','BAM','Sarajevo','Europe','Southern Europe',43.9159,17.6791,'https://flagcdn.com/w320/ba.png'),
                                                                                                                                                                                      (23,'Botswana','Republic of Botswana','BW','BWA','072','+267','BWP','Gaborone','Africa','Southern Africa',-22.3285,24.6849,'https://flagcdn.com/w320/bw.png'),
                                                                                                                                                                                      (24,'Brazil','Federative Republic of Brazil','BR','BRA','076','+55','BRL','Brasília','South America','South America',-14.2350,-51.9253,'https://flagcdn.com/w320/br.png'),
                                                                                                                                                                                      (25,'Brunei','Nation of Brunei, the Abode of Peace','BN','BRN','096','+673','BND','Bandar Seri Begawan','Asia','South-Eastern Asia',4.5353,114.7277,'https://flagcdn.com/w320/bn.png'),
                                                                                                                                                                                      (26,'Bulgaria','Republic of Bulgaria','BG','BGR','100','+359','BGN','Sofia','Europe','Eastern Europe',42.7339,25.4858,'https://flagcdn.com/w320/bg.png'),
                                                                                                                                                                                      (27,'Burkina Faso','Burkina Faso','BF','BFA','854','+226','XOF','Ouagadougou','Africa','Western Africa',12.2383,-1.5616,'https://flagcdn.com/w320/bf.png'),
                                                                                                                                                                                      (28,'Burundi','Republic of Burundi','BI','BDI','108','+257','BIF','Gitega','Africa','Eastern Africa',-3.3731,29.9189,'https://flagcdn.com/w320/bi.png'),
                                                                                                                                                                                      (29,'Cabo Verde','Republic of Cabo Verde','CV','CPV','132','+238','CVE','Praia','Africa','Western Africa',16.5388,-23.0418,'https://flagcdn.com/w320/cv.png'),
                                                                                                                                                                                      (30,'Cambodia','Kingdom of Cambodia','KH','KHM','116','+855','KHR','Phnom Penh','Asia','South-Eastern Asia',12.5657,104.9910,'https://flagcdn.com/w320/kh.png'),
                                                                                                                                                                                      (31,'Cameroon','Republic of Cameroon','CM','CMR','120','+237','XAF','Yaoundé','Africa','Middle Africa',7.3697,12.3547,'https://flagcdn.com/w320/cm.png'),
                                                                                                                                                                                      (32,'Canada','Canada','CA','CAN','124','+1','CAD','Ottawa','North America','Northern America',56.1304,-106.3468,'https://flagcdn.com/w320/ca.png'),
                                                                                                                                                                                      (33,'Central African Republic','Central African Republic','CF','CAF','140','+236','XAF','Bangui','Africa','Middle Africa',6.6111,20.9394,'https://flagcdn.com/w320/cf.png'),
                                                                                                                                                                                      (34,'Chad','Republic of Chad','TD','TCD','148','+235','XAF','N''Djamena','Africa','Middle Africa',15.4542,18.7322,'https://flagcdn.com/w320/td.png'),
                                                                                                                                                                                      (35,'Chile','Republic of Chile','CL','CHL','152','+56','CLP','Santiago','South America','South America',-35.6751,-71.5430,'https://flagcdn.com/w320/cl.png'),
                                                                                                                                                                                      (36,'China','People''s Republic of China','CN','CHN','156','+86','CNY','Beijing','Asia','Eastern Asia',35.8617,104.1954,'https://flagcdn.com/w320/cn.png'),
                                                                                                                                                                                      (37,'Colombia','Republic of Colombia','CO','COL','170','+57','COP','Bogotá','South America','South America',4.5709,-74.2973,'https://flagcdn.com/w320/co.png'),
                                                                                                                                                                                      (38,'Comoros','Union of the Comoros','KM','COM','174','+269','KMF','Moroni','Africa','Eastern Africa',-11.6455,43.3333,'https://flagcdn.com/w320/km.png'),
                                                                                                                                                                                      (39,'Congo (Congo-Brazzaville)','Republic of the Congo','CG','COG','178','+242','XAF','Brazzaville','Africa','Middle Africa',-0.2280,15.8277,'https://flagcdn.com/w320/cg.png'),
                                                                                                                                                                                      (40,'Costa Rica','Republic of Costa Rica','CR','CRI','188','+506','CRC','San José','North America','Central America',9.7489,-83.7534,'https://flagcdn.com/w320/cr.png'),
                                                                                                                                                                                      (41,'Croatia','Republic of Croatia','HR','HRV','191','+385','EUR','Zagreb','Europe','Southern Europe',45.1000,15.2000,'https://flagcdn.com/w320/hr.png'),
                                                                                                                                                                                      (42,'Cuba','Republic of Cuba','CU','CUB','192','+53','CUP','Havana','North America','Caribbean',21.5218,-77.7812,'https://flagcdn.com/w320/cu.png'),
                                                                                                                                                                                      (43,'Cyprus','Republic of Cyprus','CY','CYP','196','+357','EUR','Nicosia','Asia','Western Asia',35.1264,33.4299,'https://flagcdn.com/w320/cy.png'),
                                                                                                                                                                                      (44,'Czechia','Czech Republic','CZ','CZE','203','+420','CZK','Prague','Europe','Eastern Europe',49.8175,15.4730,'https://flagcdn.com/w320/cz.png'),
                                                                                                                                                                                      (45,'Denmark','Kingdom of Denmark','DK','DNK','208','+45','DKK','Copenhagen','Europe','Northern Europe',56.2639,9.5018,'https://flagcdn.com/w320/dk.png'),
                                                                                                                                                                                      (46,'Djibouti','Republic of Djibouti','DJ','DJI','262','+253','DJF','Djibouti','Africa','Eastern Africa',11.8251,42.5903,'https://flagcdn.com/w320/dj.png'),
                                                                                                                                                                                      (47,'Dominica','Commonwealth of Dominica','DM','DMA','212','+1-767','XCD','Roseau','North America','Caribbean',15.4150,-61.3710,'https://flagcdn.com/w320/dm.png'),
                                                                                                                                                                                      (48,'Dominican Republic','Dominican Republic','DO','DOM','214','+1-809','DOP','Santo Domingo','North America','Caribbean',18.7357,-70.1627,'https://flagcdn.com/w320/do.png'),
                                                                                                                                                                                      (49,'Ecuador','Republic of Ecuador','EC','ECU','218','+593','USD','Quito','South America','South America',-1.8312,-78.1834,'https://flagcdn.com/w320/ec.png'),
                                                                                                                                                                                      (50,'Egypt','Arab Republic of Egypt','EG','EGY','818','+20','EGP','Cairo','Africa','Northern Africa',26.8206,30.8025,'https://flagcdn.com/w320/eg.png'),
                                                                                                                                                                                      (51,'El Salvador','Republic of El Salvador','SV','SLV','222','+503','USD','San Salvador','North America','Central America',13.7942,-88.8965,'https://flagcdn.com/w320/sv.png'),
                                                                                                                                                                                      (52,'Equatorial Guinea','Republic of Equatorial Guinea','GQ','GNQ','226','+240','XAF','Malabo','Africa','Middle Africa',1.6508,10.2679,'https://flagcdn.com/w320/gq.png'),
                                                                                                                                                                                      (53,'Eritrea','State of Eritrea','ER','ERI','232','+291','ERN','Asmara','Africa','Eastern Africa',15.1794,39.7823,'https://flagcdn.com/w320/er.png'),
                                                                                                                                                                                      (54,'Estonia','Republic of Estonia','EE','EST','233','+372','EUR','Tallinn','Europe','Northern Europe',58.5953,25.0136,'https://flagcdn.com/w320/ee.png'),
                                                                                                                                                                                      (55,'Eswatini','Kingdom of Eswatini','SZ','SWZ','748','+268','SZL','Mbabane','Africa','Southern Africa',-26.5225,31.4659,'https://flagcdn.com/w320/sz.png'),
                                                                                                                                                                                      (56,'Ethiopia','Federal Democratic Republic of Ethiopia','ET','ETH','231','+251','ETB','Addis Ababa','Africa','Eastern Africa',9.1450,40.4897,'https://flagcdn.com/w320/et.png'),
                                                                                                                                                                                      (57,'Fiji','Republic of Fiji','FJ','FJI','242','+679','FJD','Suva','Oceania','Melanesia',-17.7134,178.0650,'https://flagcdn.com/w320/fj.png'),
                                                                                                                                                                                      (58,'Finland','Republic of Finland','FI','FIN','246','+358','EUR','Helsinki','Europe','Northern Europe',61.9241,25.7482,'https://flagcdn.com/w320/fi.png'),
                                                                                                                                                                                      (59,'France','French Republic','FR','FRA','250','+33','EUR','Paris','Europe','Western Europe',46.6034,1.8883,'https://flagcdn.com/w320/fr.png'),
                                                                                                                                                                                      (60,'Gabon','Gabonese Republic','GA','GAB','266','+241','XAF','Libreville','Africa','Middle Africa',-0.8037,11.6094,'https://flagcdn.com/w320/ga.png'),
                                                                                                                                                                                      (61,'Gambia','Republic of The Gambia','GM','GMB','270','+220','GMD','Banjul','Africa','Western Africa',13.4432,-15.3101,'https://flagcdn.com/w320/gm.png'),
                                                                                                                                                                                      (62,'Georgia','Georgia','GE','GEO','268','+995','GEL','Tbilisi','Asia','Western Asia',42.3154,43.3569,'https://flagcdn.com/w320/ge.png'),
                                                                                                                                                                                      (63,'Germany','Federal Republic of Germany','DE','DEU','276','+49','EUR','Berlin','Europe','Western Europe',51.1657,10.4515,'https://flagcdn.com/w320/de.png'),
                                                                                                                                                                                      (64,'Ghana','Republic of Ghana','GH','GHA','288','+233','GHS','Accra','Africa','Western Africa',7.9465,-1.0232,'https://flagcdn.com/w320/gh.png'),
                                                                                                                                                                                      (65,'Greece','Hellenic Republic','GR','GRC','300','+30','EUR','Athens','Europe','Southern Europe',39.0742,21.8243,'https://flagcdn.com/w320/gr.png'),
                                                                                                                                                                                      (66,'Grenada','Grenada','GD','GRD','308','+1-473','XCD','Saint George''s','North America','Caribbean',12.1165,-61.6790,'https://flagcdn.com/w320/gd.png'),
                                                                                                                                                                                      (67,'Guatemala','Republic of Guatemala','GT','GTM','320','+502','GTQ','Guatemala City','North America','Central America',15.7835,-90.2308,'https://flagcdn.com/w320/gt.png'),
                                                                                                                                                                                      (68,'Guinea','Republic of Guinea','GN','GIN','324','+224','GNF','Conakry','Africa','Western Africa',9.9456,-9.6966,'https://flagcdn.com/w320/gn.png'),
                                                                                                                                                                                      (69,'Guinea-Bissau','Republic of Guinea-Bissau','GW','GNB','624','+245','XOF','Bissau','Africa','Western Africa',11.8037,-15.1804,'https://flagcdn.com/w320/gw.png'),
                                                                                                                                                                                      (70,'Guyana','Co-operative Republic of Guyana','GY','GUY','328','+592','GYD','Georgetown','South America','South America',4.8604,-58.9302,'https://flagcdn.com/w320/gy.png'),
                                                                                                                                                                                      (71,'Haiti','Republic of Haiti','HT','HTI','332','+509','HTG','Port-au-Prince','North America','Caribbean',18.9712,-72.2852,'https://flagcdn.com/w320/ht.png'),
                                                                                                                                                                                      (72,'Honduras','Republic of Honduras','HN','HND','340','+504','HNL','Tegucigalpa','North America','Central America',15.2000,-86.2419,'https://flagcdn.com/w320/hn.png'),
                                                                                                                                                                                      (73,'Hungary','Hungary','HU','HUN','348','+36','HUF','Budapest','Europe','Eastern Europe',47.1625,19.5033,'https://flagcdn.com/w320/hu.png'),
                                                                                                                                                                                      (74,'Iceland','Republic of Iceland','IS','ISL','352','+354','ISK','Reykjavík','Europe','Northern Europe',64.9631,-19.0208,'https://flagcdn.com/w320/is.png'),
                                                                                                                                                                                      (75,'India','Republic of India','IN','IND','356','+91','INR','New Delhi','Asia','Southern Asia',20.5937,78.9629,'https://flagcdn.com/w320/in.png'),
                                                                                                                                                                                      (76,'Indonesia','Republic of Indonesia','ID','IDN','360','+62','IDR','Jakarta','Asia','South-Eastern Asia',-0.7893,113.9213,'https://flagcdn.com/w320/id.png'),
                                                                                                                                                                                      (77,'Iran','Islamic Republic of Iran','IR','IRN','364','+98','IRR','Tehran','Asia','Southern Asia',32.4279,53.6880,'https://flagcdn.com/w320/ir.png'),
                                                                                                                                                                                      (78,'Iraq','Republic of Iraq','IQ','IRQ','368','+964','IQD','Baghdad','Asia','Western Asia',33.2232,43.6793,'https://flagcdn.com/w320/iq.png'),
                                                                                                                                                                                      (79,'Ireland','Republic of Ireland','IE','IRL','372','+353','EUR','Dublin','Europe','Northern Europe',53.1424,-7.6921,'https://flagcdn.com/w320/ie.png'),
                                                                                                                                                                                      (80,'Israel','State of Israel','IL','ISR','376','+972','ILS','Jerusalem','Asia','Western Asia',31.0461,34.8516,'https://flagcdn.com/w320/il.png'),
                                                                                                                                                                                      (81,'Italy','Italian Republic','IT','ITA','380','+39','EUR','Rome','Europe','Southern Europe',41.8719,12.5674,'https://flagcdn.com/w320/it.png'),
                                                                                                                                                                                      (82,'Jamaica','Jamaica','JM','JAM','388','+1-876','JMD','Kingston','North America','Caribbean',18.1096,-77.2975,'https://flagcdn.com/w320/jm.png'),
                                                                                                                                                                                      (83,'Japan','Japan','JP','JPN','392','+81','JPY','Tokyo','Asia','Eastern Asia',36.2048,138.2529,'https://flagcdn.com/w320/jp.png'),
                                                                                                                                                                                      (84,'Jordan','Hashemite Kingdom of Jordan','JO','JOR','400','+962','JOD','Amman','Asia','Western Asia',30.5852,36.2384,'https://flagcdn.com/w320/jo.png'),
                                                                                                                                                                                      (85,'Kazakhstan','Republic of Kazakhstan','KZ','KAZ','398','+7','KZT','Astana','Asia','Central Asia',48.0196,66.9237,'https://flagcdn.com/w320/kz.png'),
                                                                                                                                                                                      (86,'Kenya','Republic of Kenya','KE','KEN','404','+254','KES','Nairobi','Africa','Eastern Africa',-0.0236,37.9062,'https://flagcdn.com/w320/ke.png'),
                                                                                                                                                                                      (87,'Kiribati','Republic of Kiribati','KI','KIR','296','+686','AUD','South Tarawa','Oceania','Micronesia',-3.3704,-168.7340,'https://flagcdn.com/w320/ki.png'),
                                                                                                                                                                                      (88,'Kuwait','State of Kuwait','KW','KWT','414','+965','KWD','Kuwait City','Asia','Western Asia',29.3117,47.4818,'https://flagcdn.com/w320/kw.png'),
                                                                                                                                                                                      (89,'Kyrgyzstan','Kyrgyz Republic','KG','KGZ','417','+996','KGS','Bishkek','Asia','Central Asia',41.2044,74.7661,'https://flagcdn.com/w320/kg.png'),
                                                                                                                                                                                      (90,'Laos','Lao People''s Democratic Republic','LA','LAO','418','+856','LAK','Vientiane','Asia','South-Eastern Asia',19.8563,102.4955,'https://flagcdn.com/w320/la.png'),
                                                                                                                                                                                      (91,'Latvia','Republic of Latvia','LV','LVA','428','+371','EUR','Riga','Europe','Northern Europe',56.8796,24.6032,'https://flagcdn.com/w320/lv.png'),
                                                                                                                                                                                      (92,'Lebanon','Lebanese Republic','LB','LBN','422','+961','LBP','Beirut','Asia','Western Asia',33.8547,35.8623,'https://flagcdn.com/w320/lb.png'),
                                                                                                                                                                                      (93,'Lesotho','Kingdom of Lesotho','LS','LSO','426','+266','LSL','Maseru','Africa','Southern Africa',-29.6100,28.2336,'https://flagcdn.com/w320/ls.png'),
                                                                                                                                                                                      (94,'Liberia','Republic of Liberia','LR','LBR','430','+231','LRD','Monrovia','Africa','Western Africa',6.4281,-9.4295,'https://flagcdn.com/w320/lr.png'),
                                                                                                                                                                                      (95,'Libya','State of Libya','LY','LBY','434','+218','LYD','Tripoli','Africa','Northern Africa',26.3351,17.2283,'https://flagcdn.com/w320/ly.png'),
                                                                                                                                                                                      (96,'Liechtenstein','Principality of Liechtenstein','LI','LIE','438','+423','CHF','Vaduz','Europe','Western Europe',47.1660,9.5554,'https://flagcdn.com/w320/li.png'),
                                                                                                                                                                                      (97,'Lithuania','Republic of Lithuania','LT','LTU','440','+370','EUR','Vilnius','Europe','Northern Europe',55.1694,23.8813,'https://flagcdn.com/w320/lt.png'),
                                                                                                                                                                                      (98,'Luxembourg','Grand Duchy of Luxembourg','LU','LUX','442','+352','EUR','Luxembourg','Europe','Western Europe',49.8153,6.1296,'https://flagcdn.com/w320/lu.png'),
                                                                                                                                                                                      (99,'Madagascar','Republic of Madagascar','MG','MDG','450','+261','MGA','Antananarivo','Africa','Eastern Africa',-18.7669,46.8691,'https://flagcdn.com/w320/mg.png'),
                                                                                                                                                                                      (100,'Malawi','Republic of Malawi','MW','MWI','454','+265','MWK','Lilongwe','Africa','Eastern Africa',-13.2543,34.3015,'https://flagcdn.com/w320/mw.png'),
                                                                                                                                                                                      (101, 'Monaco', 'Principality of Monaco', 'MC', 'MCO', '492', '+377', 'EUR', 'Monaco', 'Europe', 'Western Europe', 43.7384, 7.4246, 'https://flagcdn.com/w320/mc.png'),
                                                                                                                                                                                      (102, 'Mongolia', 'Mongolia', 'MN', 'MNG', '496', '+976', 'MNT', 'Ulaanbaatar', 'Asia', 'Eastern Asia', 47.8864, 106.9057, 'https://flagcdn.com/w320/mn.png'),
                                                                                                                                                                                      (103, 'Montenegro', 'Montenegro', 'ME', 'MNE', '499', '+382', 'EUR', 'Podgorica', 'Europe', 'Southern Europe', 42.4304, 19.2594, 'https://flagcdn.com/w320/me.png'),
                                                                                                                                                                                      (104, 'Morocco', 'Kingdom of Morocco', 'MA', 'MAR', '504', '+212', 'MAD', 'Rabat', 'Africa', 'Northern Africa', 34.0209, -6.8416, 'https://flagcdn.com/w320/ma.png'),
                                                                                                                                                                                      (105, 'Mozambique', 'Republic of Mozambique', 'MZ', 'MOZ', '508', '+258', 'MZN', 'Maputo', 'Africa', 'Eastern Africa', -25.9692, 32.5732, 'https://flagcdn.com/w320/mz.png'),
                                                                                                                                                                                      (106, 'Myanmar', 'Republic of the Union of Myanmar', 'MM', 'MMR', '104', '+95', 'MMK', 'Naypyidaw', 'Asia', 'South-Eastern Asia', 19.7633, 96.0785, 'https://flagcdn.com/w320/mm.png'),
                                                                                                                                                                                      (107, 'Namibia', 'Republic of Namibia', 'NA', 'NAM', '516', '+264', 'NAD', 'Windhoek', 'Africa', 'Southern Africa', -22.5609, 17.0658, 'https://flagcdn.com/w320/na.png'),
                                                                                                                                                                                      (108, 'Nauru', 'Republic of Nauru', 'NR', 'NRU', '520', '+674', 'AUD', 'Yaren', 'Oceania', 'Micronesia', -0.5477, 166.9209, 'https://flagcdn.com/w320/nr.png'),
                                                                                                                                                                                      (109, 'Nepal', 'Federal Democratic Republic of Nepal', 'NP', 'NPL', '524', '+977', 'NPR', 'Kathmandu', 'Asia', 'Southern Asia', 27.7172, 85.3240, 'https://flagcdn.com/w320/np.png'),
                                                                                                                                                                                      (110, 'Netherlands', 'Kingdom of the Netherlands', 'NL', 'NLD', '528', '+31', 'EUR', 'Amsterdam', 'Europe', 'Western Europe', 52.3676, 4.9041, 'https://flagcdn.com/w320/nl.png'),
                                                                                                                                                                                      (111, 'New Zealand', 'New Zealand', 'NZ', 'NZL', '554', '+64', 'NZD', 'Wellington', 'Oceania', 'Australia and New Zealand', -41.2866, 174.7756, 'https://flagcdn.com/w320/nz.png'),
                                                                                                                                                                                      (112, 'Nicaragua', 'Republic of Nicaragua', 'NI', 'NIC', '558', '+505', 'NIO', 'Managua', 'Americas', 'Central America', 12.1140, -86.2362, 'https://flagcdn.com/w320/ni.png'),
                                                                                                                                                                                      (113, 'Niger', 'Republic of the Niger', 'NE', 'NER', '562', '+227', 'XOF', 'Niamey', 'Africa', 'Western Africa', 13.5127, 2.1126, 'https://flagcdn.com/w320/ne.png'),
                                                                                                                                                                                      (114, 'Nigeria', 'Federal Republic of Nigeria', 'NG', 'NGA', '566', '+234', 'NGN', 'Abuja', 'Africa', 'Western Africa', 9.0765, 7.3986, 'https://flagcdn.com/w320/ng.png'),
                                                                                                                                                                                      (115, 'North Korea', 'Democratic People''s Republic of Korea', 'KP', 'PRK', '408', '+850', 'KPW', 'Pyongyang', 'Asia', 'Eastern Asia', 39.0392, 125.7625, 'https://flagcdn.com/w320/kp.png'),
                                                                                                                                                                                      (116, 'North Macedonia', 'Republic of North Macedonia', 'MK', 'MKD', '807', '+389', 'MKD', 'Skopje', 'Europe', 'Southern Europe', 41.9973, 21.4280, 'https://flagcdn.com/w320/mk.png'),
                                                                                                                                                                                      (117, 'Norway', 'Kingdom of Norway', 'NO', 'NOR', '578', '+47', 'NOK', 'Oslo', 'Europe', 'Northern Europe', 59.9139, 10.7522, 'https://flagcdn.com/w320/no.png'),
                                                                                                                                                                                      (118, 'Oman', 'Sultanate of Oman', 'OM', 'OMN', '512', '+968', 'OMR', 'Muscat', 'Asia', 'Western Asia', 23.5880, 58.3829, 'https://flagcdn.com/w320/om.png'),
                                                                                                                                                                                      (119, 'Pakistan', 'Islamic Republic of Pakistan', 'PK', 'PAK', '586', '+92', 'PKR', 'Islamabad', 'Asia', 'Southern Asia', 33.6844, 73.0479, 'https://flagcdn.com/w320/pk.png'),
                                                                                                                                                                                      (120, 'Palau', 'Republic of Palau', 'PW', 'PLW', '585', '+680', 'USD', 'Ngerulmud', 'Oceania', 'Micronesia', 7.5000, 134.6240, 'https://flagcdn.com/w320/pw.png'),
                                                                                                                                                                                      (121, 'Panama', 'Republic of Panama', 'PA', 'PAN', '591', '+507', 'PAB', 'Panama City', 'Americas', 'Central America', 8.9824, -79.5199, 'https://flagcdn.com/w320/pa.png'),
                                                                                                                                                                                      (122, 'Papua New Guinea', 'Independent State of Papua New Guinea', 'PG', 'PNG', '598', '+675', 'PGK', 'Port Moresby', 'Oceania', 'Melanesia', -9.4438, 147.1803, 'https://flagcdn.com/w320/pg.png'),
                                                                                                                                                                                      (123, 'Paraguay', 'Republic of Paraguay', 'PY', 'PRY', '600', '+595', 'PYG', 'Asunción', 'Americas', 'South America', -25.2637, -57.5759, 'https://flagcdn.com/w320/py.png'),
                                                                                                                                                                                      (124, 'Peru', 'Republic of Peru', 'PE', 'PER', '604', '+51', 'PEN', 'Lima', 'Americas', 'South America', -12.0464, -77.0428, 'https://flagcdn.com/w320/pe.png'),
                                                                                                                                                                                      (125, 'Philippines', 'Republic of the Philippines', 'PH', 'PHL', '608', '+63', 'PHP', 'Manila', 'Asia', 'South-Eastern Asia', 14.5995, 120.9842, 'https://flagcdn.com/w320/ph.png'),
                                                                                                                                                                                      (126, 'Poland', 'Republic of Poland', 'PL', 'POL', '616', '+48', 'PLN', 'Warsaw', 'Europe', 'Eastern Europe', 52.2297, 21.0122, 'https://flagcdn.com/w320/pl.png'),
                                                                                                                                                                                      (127, 'Portugal', 'Portuguese Republic', 'PT', 'PRT', '620', '+351', 'EUR', 'Lisbon', 'Europe', 'Southern Europe', 38.7223, -9.1393, 'https://flagcdn.com/w320/pt.png'),
                                                                                                                                                                                      (128, 'Qatar', 'State of Qatar', 'QA', 'QAT', '634', '+974', 'QAR', 'Doha', 'Asia', 'Western Asia', 25.2854, 51.5310, 'https://flagcdn.com/w320/qa.png'),
                                                                                                                                                                                      (129, 'Romania', 'Romania', 'RO', 'ROU', '642', '+40', 'RON', 'Bucharest', 'Europe', 'Eastern Europe', 44.4268, 26.1025, 'https://flagcdn.com/w320/ro.png'),
                                                                                                                                                                                      (130, 'Russia', 'Russian Federation', 'RU', 'RUS', '643', '+7', 'RUB', 'Moscow', 'Europe', 'Eastern Europe', 55.7558, 37.6173, 'https://flagcdn.com/w320/ru.png'),
                                                                                                                                                                                      (131, 'Rwanda', 'Republic of Rwanda', 'RW', 'RWA', '646', '+250', 'RWF', 'Kigali', 'Africa', 'Eastern Africa', -1.9441, 30.0619, 'https://flagcdn.com/w320/rw.png'),
                                                                                                                                                                                      (132, 'Saint Kitts and Nevis', 'Federation of Saint Christopher and Nevis', 'KN', 'KNA', '659', '+1-869', 'XCD', 'Basseterre', 'Americas', 'Caribbean', 17.3026, -62.7177, 'https://flagcdn.com/w320/kn.png'),
                                                                                                                                                                                      (133, 'Saint Lucia', 'Saint Lucia', 'LC', 'LCA', '662', '+1-758', 'XCD', 'Castries', 'Americas', 'Caribbean', 14.0101, -60.9875, 'https://flagcdn.com/w320/lc.png'),
                                                                                                                                                                                      (134, 'Saint Vincent and the Grenadines', 'Saint Vincent and the Grenadines', 'VC', 'VCT', '670', '+1-784', 'XCD', 'Kingstown', 'Americas', 'Caribbean', 13.1600, -61.2248, 'https://flagcdn.com/w320/vc.png'),
                                                                                                                                                                                      (135, 'Samoa', 'Independent State of Samoa', 'WS', 'WSM', '882', '+685', 'WST', 'Apia', 'Oceania', 'Polynesia', -13.8500, -171.7500, 'https://flagcdn.com/w320/ws.png'),
                                                                                                                                                                                      (136, 'San Marino', 'Republic of San Marino', 'SM', 'SMR', '674', '+378', 'EUR', 'San Marino', 'Europe', 'Southern Europe', 43.9424, 12.4578, 'https://flagcdn.com/w320/sm.png'),
                                                                                                                                                                                      (137, 'Sao Tome and Principe', 'Democratic Republic of Sao Tome and Principe', 'ST', 'STP', '678', '+239', 'STN', 'Sao Tome', 'Africa', 'Middle Africa', 0.3365, 6.7273, 'https://flagcdn.com/w320/st.png'),
                                                                                                                                                                                      (138, 'Saudi Arabia', 'Kingdom of Saudi Arabia', 'SA', 'SAU', '682', '+966', 'SAR', 'Riyadh', 'Asia', 'Western Asia', 24.7136, 46.6753, 'https://flagcdn.com/w320/sa.png'),
                                                                                                                                                                                      (139, 'Senegal', 'Republic of Senegal', 'SN', 'SEN', '686', '+221', 'XOF', 'Dakar', 'Africa', 'Western Africa', 14.7167, -17.4677, 'https://flagcdn.com/w320/sn.png'),
                                                                                                                                                                                      (140, 'Serbia', 'Republic of Serbia', 'RS', 'SRB', '688', '+381', 'RSD', 'Belgrade', 'Europe', 'Southern Europe', 44.7866, 20.4489, 'https://flagcdn.com/w320/rs.png'),
                                                                                                                                                                                      (141, 'Seychelles', 'Republic of Seychelles', 'SC', 'SYC', '690', '+248', 'SCR', 'Victoria', 'Africa', 'Eastern Africa', -4.6191, 55.4513, 'https://flagcdn.com/w320/sc.png'),
                                                                                                                                                                                      (142, 'Sierra Leone', 'Republic of Sierra Leone', 'SL', 'SLE', '694', '+232', 'SLL', 'Freetown', 'Africa', 'Western Africa', 8.4657, -13.2317, 'https://flagcdn.com/w320/sl.png'),
                                                                                                                                                                                      (143, 'Singapore', 'Republic of Singapore', 'SG', 'SGP', '702', '+65', 'SGD', 'Singapore', 'Asia', 'South-Eastern Asia', 1.3521, 103.8198, 'https://flagcdn.com/w320/sg.png'),
                                                                                                                                                                                      (144, 'Slovakia', 'Slovak Republic', 'SK', 'SVK', '703', '+421', 'EUR', 'Bratislava', 'Europe', 'Eastern Europe', 48.1486, 17.1077, 'https://flagcdn.com/w320/sk.png'),
                                                                                                                                                                                      (145, 'Slovenia', 'Republic of Slovenia', 'SI', 'SVN', '705', '+386', 'EUR', 'Ljubljana', 'Europe', 'Southern Europe', 46.0569, 14.5058, 'https://flagcdn.com/w320/si.png'),
                                                                                                                                                                                      (146, 'Solomon Islands', 'Solomon Islands', 'SB', 'SLB', '090', '+677', 'SBD', 'Honiara', 'Oceania', 'Melanesia', -9.4456, 159.9729, 'https://flagcdn.com/w320/sb.png'),
                                                                                                                                                                                      (147, 'Somalia', 'Federal Republic of Somalia', 'SO', 'SOM', '706', '+252', 'SOS', 'Mogadishu', 'Africa', 'Eastern Africa', 2.0469, 45.3182, 'https://flagcdn.com/w320/so.png'),
                                                                                                                                                                                      (148, 'South Africa', 'Republic of South Africa', 'ZA', 'ZAF', '710', '+27', 'ZAR', 'Pretoria', 'Africa', 'Southern Africa', -25.7479, 28.2293, 'https://flagcdn.com/w320/za.png'),
                                                                                                                                                                                      (149, 'South Korea', 'Republic of Korea', 'KR', 'KOR', '410', '+82', 'KRW', 'Seoul', 'Asia', 'Eastern Asia', 37.5665, 126.9780, 'https://flagcdn.com/w320/kr.png'),
                                                                                                                                                                                      (150, 'South Sudan', 'Republic of South Sudan', 'SS', 'SSD', '728', '+211', 'SSP', 'Juba', 'Africa', 'Eastern Africa', 4.8594, 31.5713, 'https://flagcdn.com/w320/ss.png'),
                                                                                                                                                                                      (151, 'Spain', 'Kingdom of Spain', 'ES', 'ESP', '724', '+34', 'EUR', 'Madrid', 'Europe', 'Southern Europe', 40.4168, -3.7038, 'https://flagcdn.com/w320/es.png'),
                                                                                                                                                                                      (152, 'Sri Lanka', 'Democratic Socialist Republic of Sri Lanka', 'LK', 'LKA', '144', '+94', 'LKR', 'Sri Jayawardenepura Kotte', 'Asia', 'Southern Asia', 6.9271, 79.8612, 'https://flagcdn.com/w320/lk.png'),
                                                                                                                                                                                      (153, 'Sudan', 'Republic of the Sudan', 'SD', 'SDN', '729', '+249', 'SDG', 'Khartoum', 'Africa', 'Northern Africa', 15.5007, 32.5599, 'https://flagcdn.com/w320/sd.png'),
                                                                                                                                                                                      (154, 'Suriname', 'Republic of Suriname', 'SR', 'SUR', '740', '+597', 'SRD', 'Paramaribo', 'Americas', 'South America', 5.8520, -55.2038, 'https://flagcdn.com/w320/sr.png'),
                                                                                                                                                                                      (155, 'Sweden', 'Kingdom of Sweden', 'SE', 'SWE', '752', '+46', 'SEK', 'Stockholm', 'Europe', 'Northern Europe', 59.3293, 18.0686, 'https://flagcdn.com/w320/se.png'),
                                                                                                                                                                                      (156, 'Switzerland', 'Swiss Confederation', 'CH', 'CHE', '756', '+41', 'CHF', 'Bern', 'Europe', 'Western Europe', 46.9480, 7.4474, 'https://flagcdn.com/w320/ch.png'),
                                                                                                                                                                                      (157, 'Syria', 'Syrian Arab Republic', 'SY', 'SYR', '760', '+963', 'SYP', 'Damascus', 'Asia', 'Western Asia', 33.5138, 36.2765, 'https://flagcdn.com/w320/sy.png'),
                                                                                                                                                                                      (158, 'Taiwan', 'Republic of China (Taiwan)', 'TW', 'TWN', '158', '+886', 'TWD', 'Taipei', 'Asia', 'Eastern Asia', 25.0330, 121.5654, 'https://flagcdn.com/w320/tw.png'),
                                                                                                                                                                                      (159, 'Tajikistan', 'Republic of Tajikistan', 'TJ', 'TJK', '762', '+992', 'TJS', 'Dushanbe', 'Asia', 'Central Asia', 38.5598, 68.7870, 'https://flagcdn.com/w320/tj.png'),
                                                                                                                                                                                      (160, 'Tanzania', 'United Republic of Tanzania', 'TZ', 'TZA', '834', '+255', 'TZS', 'Dodoma', 'Africa', 'Eastern Africa', -6.1630, 35.7516, 'https://flagcdn.com/w320/tz.png'),
                                                                                                                                                                                      (161, 'Thailand', 'Kingdom of Thailand', 'TH', 'THA', '764', '+66', 'THB', 'Bangkok', 'Asia', 'South-Eastern Asia', 13.7563, 100.5018, 'https://flagcdn.com/w320/th.png'),
                                                                                                                                                                                      (162, 'Timor-Leste', 'Democratic Republic of Timor-Leste', 'TL', 'TLS', '626', '+670', 'USD', 'Dili', 'Asia', 'South-Eastern Asia', -8.5569, 125.5603, 'https://flagcdn.com/w320/tl.png'),
                                                                                                                                                                                      (163, 'Togo', 'Togolese Republic', 'TG', 'TGO', '768', '+228', 'XOF', 'Lome', 'Africa', 'Western Africa', 6.1319, 1.2228, 'https://flagcdn.com/w320/tg.png'),
                                                                                                                                                                                      (164, 'Tonga', 'Kingdom of Tonga', 'TO', 'TON', '776', '+676', 'TOP', 'Nuku''alofa', 'Oceania', 'Polynesia', -21.1394, -175.2040, 'https://flagcdn.com/w320/to.png'),
                                                                                                                                                                                      (165, 'Trinidad and Tobago', 'Republic of Trinidad and Tobago', 'TT', 'TTO', '780', '+1-868', 'TTD', 'Port of Spain', 'Americas', 'Caribbean', 10.6549, -61.5019, 'https://flagcdn.com/w320/tt.png'),
                                                                                                                                                                                      (166, 'Tunisia', 'Republic of Tunisia', 'TN', 'TUN', '788', '+216', 'TND', 'Tunis', 'Africa', 'Northern Africa', 36.8065, 10.1815, 'https://flagcdn.com/w320/tn.png'),
                                                                                                                                                                                      (167, 'Turkey', 'Republic of Turkey', 'TR', 'TUR', '792', '+90', 'TRY', 'Ankara', 'Asia', 'Western Asia', 39.9334, 32.8597, 'https://flagcdn.com/w320/tr.png'),
                                                                                                                                                                                      (168, 'Turkmenistan', 'Turkmenistan', 'TM', 'TKM', '795', '+993', 'TMT', 'Ashgabat', 'Asia', 'Central Asia', 37.9601, 58.3261, 'https://flagcdn.com/w320/tm.png'),
                                                                                                                                                                                      (169, 'Tuvalu', 'Tuvalu', 'TV', 'TUV', '798', '+688', 'AUD', 'Funafuti', 'Oceania', 'Polynesia', -8.5211, 179.1981, 'https://flagcdn.com/w320/tv.png'),
                                                                                                                                                                                      (170, 'Uganda', 'Republic of Uganda', 'UG', 'UGA', '800', '+256', 'UGX', 'Kampala', 'Africa', 'Eastern Africa', 0.3476, 32.5825, 'https://flagcdn.com/w320/ug.png'),
                                                                                                                                                                                      (171, 'Ukraine', 'Ukraine', 'UA', 'UKR', '804', '+380', 'UAH', 'Kyiv', 'Europe', 'Eastern Europe', 50.4501, 30.5234, 'https://flagcdn.com/w320/ua.png'),
                                                                                                                                                                                      (172, 'United Arab Emirates', 'United Arab Emirates', 'AE', 'ARE', '784', '+971', 'AED', 'Abu Dhabi', 'Asia', 'Western Asia', 24.4539, 54.3773, 'https://flagcdn.com/w320/ae.png'),
                                                                                                                                                                                      (173, 'United Kingdom', 'United Kingdom of Great Britain and Northern Ireland', 'GB', 'GBR', '826', '+44', 'GBP', 'London', 'Europe', 'Northern Europe', 51.5074, -0.1278, 'https://flagcdn.com/w320/gb.png'),
                                                                                                                                                                                      (174, 'United States', 'United States of America', 'US', 'USA', '840', '+1', 'USD', 'Washington, D.C.', 'Americas', 'Northern America', 38.9072, -77.0369, 'https://flagcdn.com/w320/us.png'),
                                                                                                                                                                                      (175, 'Uruguay', 'Oriental Republic of Uruguay', 'UY', 'URY', '858', '+598', 'UYU', 'Montevideo', 'Americas', 'South America', -34.9011, -56.1645, 'https://flagcdn.com/w320/uy.png'),
                                                                                                                                                                                      (176, 'Uzbekistan', 'Republic of Uzbekistan', 'UZ', 'UZB', '860', '+998', 'UZS', 'Tashkent', 'Asia', 'Central Asia', 41.2995, 69.2401, 'https://flagcdn.com/w320/uz.png'),
                                                                                                                                                                                      (177, 'Vanuatu', 'Republic of Vanuatu', 'VU', 'VUT', '548', '+678', 'VUV', 'Port Vila', 'Oceania', 'Melanesia', -17.7333, 168.3273, 'https://flagcdn.com/w320/vu.png'),
                                                                                                                                                                                      (178, 'Vatican City', 'Holy See (Vatican City State)', 'VA', 'VAT', '336', '+379', 'EUR', 'Vatican City', 'Europe', 'Southern Europe', 41.9029, 12.4534, 'https://flagcdn.com/w320/va.png'),
                                                                                                                                                                                      (179, 'Venezuela', 'Bolivarian Republic of Venezuela', 'VE', 'VEN', '862', '+58', 'VES', 'Caracas', 'Americas', 'South America', 10.4806, -66.9036, 'https://flagcdn.com/w320/ve.png'),
                                                                                                                                                                                      (180, 'Vietnam', 'Socialist Republic of Vietnam', 'VN', 'VNM', '704', '+84', 'VND', 'Hanoi', 'Asia', 'South-Eastern Asia', 21.0278, 105.8342, 'https://flagcdn.com/w320/vn.png'),
                                                                                                                                                                                      (181, 'Yemen', 'Republic of Yemen', 'YE', 'YEM', '887', '+967', 'YER', 'Sana''a', 'Asia', 'Western Asia', 15.3694, 44.1910, 'https://flagcdn.com/w320/ye.png'),
                                                                                                                                                                                      (182, 'Zambia', 'Republic of Zambia', 'ZM', 'ZMB', '894', '+260', 'ZMW', 'Lusaka', 'Africa', 'Eastern Africa', -15.3875, 28.3228, 'https://flagcdn.com/w320/zm.png'),
                                                                                                                                                                                      (183, 'Zimbabwe', 'Republic of Zimbabwe', 'ZW', 'ZWE', '716', '+263', 'ZWL', 'Harare', 'Africa', 'Eastern Africa', -17.8252, 31.0335, 'https://flagcdn.com/w320/zw.png');


-- =========================
-- core_modules
-- =========================
INSERT IGNORE INTO modules (module_name, description) VALUES
                                                          ('general_data', 'General tree info'),
                                                          ('botanical_data', 'Botanical details'),
                                                          ('ayurvedic_data', 'Ayurvedic uses'),
                                                          ('planting_data', 'Planting info'),
                                                          ('toxicity', 'Toxicity information'),
                                                          ('gardening', 'Gardening info'),
                                                          ('other_language_name', 'Names in other languages'),
                                                          ('geo_availability', 'Geographic distribution'),
                                                          ('status', 'Red Data Book / Conservation status'),
                                                          ('other', 'Any other module');





-- =========================
-- core_user_status
-- =========================
INSERT IGNORE INTO user_status (status) VALUES
                                                 ('active'),
                                                 ('inactive'),
                                                 ('suspended'),
                                                 ('pending'),
                                                 ('deleted');


-- =========================
-- core_user_roles
-- =========================
INSERT IGNORE INTO user_roles (role) VALUES
                                              ('admin'),
                                              ('super_admin'),
                                              ('researcher'),
                                              ('editor'),
                                              ('contributor'),
                                              ('viewer'),
                                              ('api_user');


-- =========================
-- general_red_databook_status
-- =========================
INSERT IGNORE INTO red_databook_status
(category_code, category_name, colour_code, description) VALUES
                                                             ('EX', 'Extinct', 'Black', 'No known living individuals'),
                                                             ('EW', 'Extinct in the Wild', 'Dark Gray', 'Survives only in cultivation'),
                                                             ('CR', 'Critically Endangered', 'Red', 'Extremely high risk of extinction'),
                                                             ('EN', 'Endangered', 'Orange Red', 'Very high risk of extinction'),
                                                             ('VU', 'Vulnerable', 'Orange', 'High risk of extinction'),
                                                             ('NT', 'Near Threatened', 'Yellow', 'Likely to become threatened'),
                                                             ('LC', 'Least Concern', 'Green', 'Lowest risk category'),
                                                             ('DD', 'Data Deficient', 'Gray', 'Insufficient information'),
                                                             ('NE', 'Not Evaluated', 'Blue', 'Not yet evaluated');


-- =========================
-- OPTIONAL: general availability enums
-- (if using normalized geo availability extension)
-- =========================
INSERT IGNORE INTO availability_statuses (status_name, description) VALUES
                                                                        ('Native', 'Naturally occurring in this region'),
                                                                        ('Endemic', 'Restricted to a specific geographic area'),
                                                                        ('Introduced', 'Introduced by humans'),
                                                                        ('Cultivated', 'Grown under cultivation'),
                                                                        ('Naturalized', 'Introduced but established in the wild');


-- =========================
-- OPTIONAL: languages master
-- =========================
INSERT IGNORE INTO languages (name, iso_code) VALUES
                                                  ('English', 'en'),
                                                  ('Sinhala', 'si'),
                                                  ('Tamil', 'ta'),
                                                  ('Hindi', 'hi'),
                                                  ('Sanskrit', 'sa'),
                                                  ('Malayalam', 'ml'),
                                                  ('Telugu', 'te'),
                                                  ('Kannada', 'kn'),
                                                  ('Arabic', 'ar'),
                                                  ('Chinese', 'zh');

