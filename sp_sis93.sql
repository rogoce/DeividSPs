-- Procedure que crea el cambo subir_bo en las diferentes tablas del sistema deivid
-- que seran usadas para subir a BO - SYBASE IQ

-- Creado    : 06/07/2007 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A

drop procedure sp_sis93;

create procedure sp_sis93()
returning integer,
          char(50);

define _renglon		integer;

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_isam || " " || trim(_error_desc);
end exception

let _renglon = 0;

-- botest
{
alter table botest add subir_bo smallint default 0;

create index idx_botest_subir_bo on botest(subir_bo);

update statistics for table botest;

update botest set subir_bo = 0;

alter table botest modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- botest    -- Procesada con Exito" with resume;
}
{
-- emipomae

let _renglon = _renglon + 1;

alter table emipomae add subir_bo smallint default 0;

create index idx_emipomae_subir_bo on emipomae(subir_bo);

update statistics for table emipomae;

update emipomae set subir_bo = 0;

alter table emipomae modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- emipomae    -- Procesada con Exito" with resume;


-- leasing

let _renglon = _renglon + 1;

alter table emipomae add leasing smallint default 0;

update emipomae set leasing = 0;

alter table emipomae modify leasing smallint default 0 not null;

return _renglon, "Tabla -- emipomae    -- Procesada con Exito" with resume;



-- endeduni

alter table endeduni add subir_bo smallint default 0;

create index idx_endeduni_subir_bo on endeduni(subir_bo);

update statistics for table endeduni;

update endeduni set subir_bo = 0;

alter table endeduni modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- endeduni    -- Procesada con Exito" with resume;


-- emipoagt

alter table emipoagt add subir_bo smallint default 0;

create index idx_emipoagt_subir_bo on emipoagt(subir_bo);

update statistics for table emipoagt;

update emipoagt set subir_bo = 0;

alter table emipoagt modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- emipoagt    -- Procesada con Exito" with resume;


-- cobremae

alter table cobremae add subir_bo smallint default 0;

create index idx_cobremae_subir_bo on cobremae(subir_bo);

update statistics for table cobremae;

update cobremae set subir_bo = 0;

alter table cobremae modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- cobremae    -- Procesada con Exito" with resume;


-- cobredet

alter table cobredet add subir_bo smallint default 0;

create index idx_cobredet_subir_bo on cobredet(subir_bo);

update statistics for table cobredet;

update cobredet set subir_bo = 0;

alter table cobredet modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- cobredet    -- Procesada con Exito" with resume;


-- rectrmae

alter table rectrmae add subir_bo smallint default 0;

create index idx_rectrmae_subir_bo on rectrmae(subir_bo);

update statistics for table rectrmae;

update rectrmae set subir_bo = 0;

alter table rectrmae modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- rectrmae    -- Procesada con Exito" with resume;


-- rectrrea

alter table rectrrea add subir_bo smallint default 0;

create index idx_rectrrea_subir_bo on rectrrea(subir_bo);

update statistics for table rectrrea;

update rectrrea set subir_bo = 0;

alter table rectrrea modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- rectrrea    -- Procesada con Exito" with resume;


-- reccoas

alter table reccoas add subir_bo smallint default 0;

create index idx_reccoas_subir_bo on reccoas(subir_bo);

update statistics for table reccoas;

update reccoas set subir_bo = 0;

alter table reccoas modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- reccoas    -- Procesada con Exito" with resume;


-- recreaco

alter table recreaco add subir_bo smallint default 0;

create index idx_recreaco_subir_bo on recreaco(subir_bo);

update statistics for table recreaco;

update recreaco set subir_bo = 0;

alter table recreaco modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- recreaco    -- Procesada con Exito" with resume;


-- endedmae

alter table endedmae add subir_bo smallint default 0;

create index idx_endedmae_subir_bo on endedmae(subir_bo);

update statistics for table endedmae;

update endedmae set subir_bo = 0;

alter table endedmae modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- endedmae    -- Procesada con Exito" with resume;


-- recrcmae

alter table recrcmae add subir_bo smallint default 0;

create index idx_recrcmae_subir_bo on recrcmae(subir_bo);

update statistics for table recrcmae;

update recrcmae set subir_bo = 0;

alter table recrcmae modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- recrcmae    -- Procesada con Exito" with resume;
}
{
-- recrecup

alter table recrecup add subir_bo smallint default 0;

create index idx_recrecup_subir_bo on recrecup(subir_bo);

update statistics for table recrecup;

update recrecup set subir_bo = 0;

alter table recrecup modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- recrecup    -- Procesada con Exito" with resume;


-- emicoami

alter table emicoami add subir_bo smallint default 0;

create index idx_emicoami_subir_bo on emicoami(subir_bo);

update statistics for table emicoami;

update emicoami set subir_bo = 0;

alter table emicoami modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- emicoami    -- Procesada con Exito" with resume;


-- emicoama

alter table emicoama add subir_bo smallint default 0;

create index idx_emicoama_subir_bo on emicoama(subir_bo);

update statistics for table emicoama;

update emicoama set subir_bo = 0;

alter table emicoama modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- emicoama    -- Procesada con Exito" with resume;
}
{
-- emifacon

let _renglon = _renglon + 1;

--alter table emifacon add subir_bo smallint default 0;

--create index idx_emifacon_subir_bo on emifacon(subir_bo);

update statistics for table emifacon;

update emifacon set subir_bo = 0;

alter table emifacon modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- emifacon    -- Procesada con Exito" with resume;


-- emifafac

let _renglon = _renglon + 1;

alter table emifafac add subir_bo smallint default 0;

create index idx_emifafac_subir_bo on emifafac(subir_bo);

update statistics for table emifafac;

update emifafac set subir_bo = 0;

alter table emifafac modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- emifafac    -- Procesada con Exito" with resume;
}

-- emipouni
{
let _renglon = _renglon + 1;

--alter table emipouni add subir_bo smallint default 0;

--create index idx_emipouni_subir_bo on emipouni(subir_bo);

update statistics for table emipouni;

update emipouni set subir_bo = 0;

alter table emipouni modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- emipouni    -- Procesada con Exito" with resume;
}
{
-- emiauto

let _renglon = _renglon + 1;

alter table emiauto add subir_bo smallint default 0;

create index idx_emiauto_subir_bo on emiauto(subir_bo);

update statistics for table emiauto;

update emiauto set subir_bo = 0;

alter table emiauto modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- emiauto    -- Procesada con Exito" with resume;


-- endmoaut

let _renglon = _renglon + 1;

alter table endmoaut add subir_bo smallint default 0;

create index idx_endmoaut_subir_bo on endmoaut(subir_bo);

update statistics for table endmoaut;

update endmoaut set subir_bo = 0;

alter table endmoaut modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- endmoaut    -- Procesada con Exito" with resume;


-- emiunide

let _renglon = _renglon + 1;

alter table emiunide add subir_bo smallint default 0;

create index idx_emiunide_subir_bo on emiunide(subir_bo);

update statistics for table emiunide;

update emiunide set subir_bo = 0;

alter table emiunide modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- emiunide    -- Procesada con Exito" with resume;


-- endunide

let _renglon = _renglon + 1;

alter table endunide add subir_bo smallint default 0;

create index idx_endunide_subir_bo on endunide(subir_bo);

update statistics for table endunide;

update endunide set subir_bo = 0;

alter table endunide modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- endunide    -- Procesada con Exito" with resume;


-- rectrcon

let _renglon = _renglon + 1;

alter table rectrcon add subir_bo smallint default 0;

create index idx_rectrcon_subir_bo on rectrcon(subir_bo);

update statistics for table rectrcon;

update rectrcon set subir_bo = 0;

alter table rectrcon modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- rectrcon    -- Procesada con Exito" with resume;


-- recrccob

let _renglon = _renglon + 1;

alter table recrccob add subir_bo smallint default 0;

create index idx_recrccob_subir_bo on recrccob(subir_bo);

update statistics for table recrccob;

update recrccob set subir_bo = 0;

alter table recrccob modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- recrccob    -- Procesada con Exito" with resume;


-- endcoama

let _renglon = _renglon + 1;

alter table endcoama add subir_bo smallint default 0;

create index idx_endcoama_subir_bo on endcoama(subir_bo);

update statistics for table endcoama;

update endcoama set subir_bo = 0;

alter table endcoama modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- endcoama    -- Procesada con Exito" with resume;


-- rectrcob

let _renglon = _renglon + 1;

alter table rectrcob add subir_bo smallint default 0;

create index idx_rectrcob_subir_bo on rectrcob(subir_bo);

update statistics for table rectrcob;

update rectrcob set subir_bo = 0;

alter table rectrcob modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- rectrcob    -- Procesada con Exito" with resume;
}

-- emipocob

let _renglon = _renglon + 1;

--alter table emipocob add subir_bo smallint default 0;

--create index idx_emipocob_subir_bo on emipocob(subir_bo);

update statistics for table emipocob;

update emipocob set subir_bo = 0;

alter table emipocob modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- emipocob    -- Procesada con Exito" with resume;


-- endedcob

let _renglon = _renglon + 1;

alter table endedcob add subir_bo smallint default 0;

create index idx_endedcob_subir_bo on endedcob(subir_bo);

update statistics for table endedcob;

update endedcob set subir_bo = 0;

alter table endedcob modify subir_bo smallint default 0 not null;

return _renglon, "Tabla -- endedcob    -- Procesada con Exito" with resume;



end

return 0, "Actualizacion Exitosa";

end procedure
