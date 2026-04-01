-- Monitoreo de las Remesas para Verificar errores en las comisiones
-- 
-- Creado    : 22/06/2004 - Autor: Demetrio Hurtado Almanza 
--

drop procedure sp_cob149;
create procedure sp_cob149(a_periodo char(7))
returning char(10),
          integer,
		  char(50),
		  char(50),
		  char(50);

define _no_remesa	char(10);
define _renglon		integer;
define _porc_partic	dec(16,2);

define _no_poliza	char(10);
define _cod_agente,_cod_agt	char(5);
define _cantidad	smallint;
define _fecha		date;

define _nombre1		char(50);
define _nombre2		char(50);

let _nombre1 = "";
let _nombre2 = "";

foreach
 select d.no_remesa,
        d.renglon,
		d.no_poliza,
		d.fecha
   into	_no_remesa,
        _renglon,
		_no_poliza,
		_fecha
   from cobredet d, cobremae m
  where d.cod_compania = "001"
    and d.actualizado  = 1
    and d.tipo_mov     in ("P", "N")
	and d.periodo      matches a_periodo
	and m.user_added   <> "GERENCIA" 
	and m.no_remesa    = d.no_remesa
	and d.no_remesa    not in ("69578", "69806", "79541", "82249", "91142", "96352", "97929") -- Remesas de Aplicacion de Saldos Creditos

	select sum(porc_partic_agt)
	  into _porc_partic
	  from cobreagt
	 where no_remesa = _no_remesa 
	   and renglon   = _renglon;

	if _porc_partic <> 100 then

		return _no_remesa,
		       _renglon,
			   "% de Participacion No Suma 100%",
			   "",
			   ""
			   with resume;
	end if
	
	foreach
		select cod_agente
		  into _cod_agente
		  from cobreagt
		 where no_remesa  = _no_remesa
		   and renglon    = _renglon

		select count(*)
		  into _cantidad
		  from emipoagt
		 where no_poliza  = _no_poliza
		   and cod_agente = _cod_agente;

		if _cantidad = 0 then
			select count(*)
			  into _cantidad
			  from endedmae
			 where no_poliza     = _no_poliza
			   and cod_endomov   in("012","031") --cambio de corredor, traspaso de cartera
			   and actualizado   = 1
			   and fecha_emision >= _fecha;

			if _cantidad = 0 then

				select count(*)
				  into _cantidad
				  from agthisun
				 where cod_documento = _no_poliza
				   and tipo_doc      = 1
				   and cod_agente_v  = _cod_agente;

				if _cantidad = 0 then

					select nombre
					  into _nombre1
					  from agtagent
					 where cod_agente = _cod_agente;
					 
					{if _no_remesa = '2149739' then	--Esto es para cuando una remesa no tiene el agente que esta en la poliza
						foreach
							 select cod_agente
							   into _cod_agt
							   from emipoagt
							  where no_poliza  = _no_poliza
							exit foreach;
						end foreach
							
						update cobreagt
						   set cod_agente = _cod_agt
						 where no_remesa  = _no_remesa
						   and renglon    = _renglon;
					end if}

					return _no_remesa,
					       _renglon,
						   "Corredor No Esta en la Poliza ...",
						   _nombre1,
						   _nombre2
						   with resume;

				end if	
			end if	
		end if	
	end foreach
end foreach

return "0", 0, "Verificacion Completada ...", "", "";

end procedure