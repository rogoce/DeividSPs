-- Procedure que crea la poliza para la U

drop procedure sp_par178;

create procedure "informix".sp_par178()
returning integer,
          char(50);

define _no_poliza		char(10);
define _no_unidad		char(5);
define _nombre			char(100);
define _cod_cliente		char(10);

define _vigencia_inic	date;
define _vigencia_final	date;

define _error			integer;
define _contador		integer;
define _numero			integer;

begin 
on exception set _error
	return _error, "Error al Actualizar el registro";
end exception

let _no_poliza = "200834";
let _contador  = 1;

select vigencia_inic,
       vigencia_final
  into _vigencia_inic,
       _vigencia_final
  from emipomae
 where no_poliza = _no_poliza;
            							
update emipouni
   set vigencia_inic  = _vigencia_inic,
       vigencia_final = _vigencia_final
 where no_poliza      = _no_poliza
   and no_unidad      = "00001";

delete from emipocob where no_poliza = _no_poliza and no_unidad <> "00001";
delete from emifacon where no_poliza = _no_poliza and no_unidad <> "00001";
delete from emipouni where no_poliza = _no_poliza and no_unidad <> "00001";

select *
  from emipouni
 where no_poliza = _no_poliza
   and no_unidad = "00001"
  into temp temp_emipouni;

select *
  from emifacon
 where no_poliza = _no_poliza
   and no_unidad = "00001"
  into temp temp_emifacon;

select *
  from emipocob
 where no_poliza = _no_poliza
   and no_unidad = "00001"
  into temp temp_emipocob;

foreach
 select nombre_deivid,
        codigo_deivid,
        numero 
   into _nombre,
        _cod_cliente,
		_numero
   from cajs
  where numero      <> 1
    and edad_deivid >= 18
	and edad_deivid <= 64
  order by numero

	-- Determinar el Numero de la Unidad

	let _contador = _contador + 1;

	LET _no_unidad  = '00000';

	IF _contador > 9999 THEN
		LET _no_unidad      = _contador;
	ELIF _contador > 999 THEN
		LET _no_unidad[2,5] = _contador;
	ELIF _contador > 99  THEN
		LET _no_unidad[3,5] = _contador;
	ELIF _contador > 9  THEN
		LET _no_unidad[4,5] = _contador;
	ELSE
		LET _no_unidad[5,5] = _contador;
	END IF

	-- Actualizar el codigo del cliente

	update temp_emipouni
	   set cod_asegurado = _cod_cliente,
	       desc_unidad   = _nombre,
	       no_unidad     = _no_unidad;
	       
	update temp_emifacon
	   set no_unidad     = _no_unidad;

	update temp_emipocob
	   set no_unidad     = _no_unidad;

	-- Insertar los nuevos registros

	insert into emipouni
	select *
	  from temp_emipouni;
	  
	insert into emifacon
	select *
	  from temp_emifacon;

	insert into emipocob
	select *
	  from temp_emipocob;

	{
	if _contador > 5 then
		exit foreach;
	end	if
	}

end foreach

drop table temp_emipouni;
drop table temp_emifacon;
drop table temp_emipocob;

end

return 0, "Actualizacion Exitosa";

end procedure
