-- Procedimiento que arregla la Cobertura de Reaseguro para las Fianzas

--drop procedure sp_par35;

create procedure sp_par35()
returning smallint, char(100);

DEFINE _error SMALLINT; 

BEGIN

ON EXCEPTION SET _error 
	rollback work;
 	RETURN _error, "Error de Base de Datos";         
END EXCEPTION           

begin work;

insert into emireama
select 
no_poliza,
no_unidad,
no_cambio,
"008",
vigencia_inic,
vigencia_final
 from emireama
where cod_cober_reas in ("023", "024");

insert into emireaco
select 
no_poliza,
no_unidad,
no_cambio,
"008",
orden,
cod_contrato,
porc_partic_suma,
porc_partic_prima
 from emireaco
where cod_cober_reas in ("023", "024");

insert into emireafa
select
no_poliza,
no_unidad,
no_cambio,
"008",
orden,
cod_contrato,
cod_coasegur,
porc_partic_reas,
porc_comis_fac,
porc_impuesto
 from emireafa
where cod_cober_reas in ("023", "024");

delete from emireafa where cod_cober_reas in ("023", "024");
delete from emireaco where cod_cober_reas in ("023", "024");
delete from emireama where cod_cober_reas in ("023", "024");

commit work;
return 0, "Actualizacion Exitosa";

end  
	
end procedure;