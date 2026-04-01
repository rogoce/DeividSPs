-- Procedimiento que crea registro de poliza temporal tabla(emiporen) para ser usado en prg. de renovaciones opciones.

-- CREADO: 24/01/2005 POR: Armando
-- MOd	 : 22/02/2004 por  Armando

drop procedure sp_pro82h;

create procedure sp_pro82h(
v_poliza 			char(10),
a_flag				integer
)

define _no_unidad			char(5);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _cod_agt				char(5);
define _porc_comis_agt		dec(5,2);
define _suma				dec(16,2);
define _cant				integer;
define _cnt					integer;
define _fecha_primer_pago	date;
define _prima_neta			dec(16,2);
define _es_terremoto        smallint;
define _prima_incendio		dec(16,2);
define _prima_terr			dec(16,2);
define _opcion              smallint;
define _porc_depre		    DEC(16,2);
let _cant  = 0;
let _porc_depre = 0.00;

set isolation to dirty read;
--begin work;
begin

--if v_poliza = '0001065914' then
--	SET DEBUG FILE TO "sp_pro82h.trc";
--	TRACE ON;
--end if

if a_flag = 1 then	--cobros
	select count(*)
	  into _cant
	  from emiporen
	 where no_poliza = v_poliza;

	if _cant = 0 then
		select * from emipomae
		  where no_poliza = v_poliza
		   into temp tmpemipo;

		insert into emiporen
		select * from tmpemipo
		 where no_poliza = v_poliza;

		foreach
			select fecha_primer_pago
			  into _fecha_primer_pago
			  from emireaut
			 where no_poliza = v_poliza
			exit foreach;
		end foreach

		update emiporen
		   set actualizado       = 0,
		       factor_vigencia   = 1.000000,
			   fecha_primer_pago = _fecha_primer_pago
		 where no_poliza         = v_poliza;

		drop table tmpemipo;
	end if
end if
if a_flag = 2 then	--corredor
	select count(*)
	  into _cant
	  from emiagtre
	 where no_poliza = v_poliza;

	if _cant = 0 then
		select cod_ramo,
		       cod_subramo
		  into _cod_ramo,
		       _cod_subramo
		  from emipomae
		 where no_poliza = v_poliza;

		select * from emipoagt
		 where no_poliza = v_poliza
		  into temp tmpemiag;

		foreach
			select cod_agente
			  into _cod_agt
			  from tmpemiag
			 where no_poliza = v_poliza

			call sp_pro305(_cod_agt,_cod_ramo,_cod_subramo) returning _porc_comis_agt;

		{	select count(*)
			  into _cnt
			  from agtcomra
			 where cod_agente = _cod_agt
			   and cod_ramo   = _cod_ramo;

			if _cnt > 0 then

				select porc_comis_agt
				  into _porc_comis_agt
				  from agtcomra
				 where cod_agente = _cod_agt
				   and cod_ramo   = _cod_ramo;

			else

				select porc_comision
				  into _porc_comis_agt
				  from prdramo
				 where cod_ramo	= _cod_ramo;

			end if }

			update tmpemiag
			   set porc_comis_agt = _porc_comis_agt
			 where cod_agente     = _cod_agt
			   and no_poliza      = v_poliza;
		end foreach

		insert into emiagtre
		select * from tmpemiag
		 where no_poliza = v_poliza;

		drop table tmpemiag;
	end if
end if
if a_flag = 3 then	--acreedor
	select count(*)
	  into _cant
	  from emireacr
	 where no_poliza = v_poliza;

	if _cant = 0 then
		select * from emipoacr
		 where no_poliza = v_poliza
		  into temp tmpemiac;

		delete from tmpemiac
		 where no_unidad not in (select no_unidad from emireaut
		   			              where tmpemiac.no_unidad = emireaut.no_unidad);

		insert into emireacr
		select * from tmpemiac
		 where no_poliza = v_poliza;

		drop table tmpemiac;
	end if
	
	foreach
	  select no_unidad,
			 suma_aseg
		into _no_unidad,
			 _suma
	    from emireaut
	   where no_poliza = v_poliza

	{  update emireacr
	     set limite = _suma
       where no_poliza = v_poliza
	     and no_unidad = _no_unidad;}
	end foreach
end if

if a_flag = 4 then	--coaseguro emicoama
	select count(*)
	  into _cant
	  from emicomar
	 where no_poliza = v_poliza;

	 if _cant = 0 then
		select * from emicoama
		 where no_poliza = v_poliza
		  into temp tmpemic1;

		insert into emicomar
		select * from tmpemic1
		 where no_poliza = v_poliza;

		drop table tmpemic1;
	end if
end if

if a_flag = 5 then	--caseguro emicoami
	select count(*)
	  into _cant
	  from emicomir
	 where no_poliza = v_poliza;

	if _cant = 0 then
		select * from emicoami
		 where no_poliza = v_poliza
		  into temp tmpemic2;

		insert into emicomir
		select * from tmpemic2
		 where no_poliza = v_poliza;

		drop table tmpemic2;
	end if
end if

if a_flag = 6 then	--coaseguro emiciara
	select count(*)
	  into _cant
	  from emiciare
	 where no_poliza = v_poliza;

	if _cant = 0 then
		select * from emiciara
		 where no_poliza = v_poliza
		  into temp tmpemic3;

		insert into emiciare
		select * from tmpemic3
		 where no_poliza = v_poliza;

		drop table tmpemic3;
	end if
end if

if a_flag = 7 then	--descripcion
	select count(*)
	  into _cant
	  from emiredes
	 where no_poliza = v_poliza;

	if _cant = 0 then
		select * from emipode2
		 where no_poliza = v_poliza
		  into temp tmpemic4;

		insert into emiredes
		select * from tmpemic4
		 where no_poliza = v_poliza;

		drop table tmpemic4;
	end if
end if

if a_flag = 8 then	--acreedor al momento de actualizar o ver preliminar
	foreach
		select no_unidad,
			   suma_aseg
		  into _no_unidad,
			   _suma
		  from emireaut
		 where no_poliza = v_poliza

		update emireacr
		   set limite = _suma
		 where no_poliza = v_poliza
		   and no_unidad = _no_unidad;
	end foreach
end if

if a_flag = 9 then	--cumulos incendio
	select count(*)
	  into _cant
	  from emirecum
	 where no_poliza = v_poliza;

	if _cant = 0 then
		select * from emicupol
		 where no_poliza = v_poliza
		  into temp tmpemic9;

		insert into emirecum
		select * from tmpemic9
		 where no_poliza = v_poliza;

		drop table tmpemic9;
	end if
	select cod_ramo into _cod_ramo from emipomae where no_poliza = v_poliza;
	if _cod_ramo not in('010','012','013','014','022') then
	foreach
		select no_unidad,
		       opcion_final
		  into _no_unidad,
			   _opcion
		  from emireaut
		 where no_poliza = v_poliza
		 
		let _prima_incendio = 0;
		let _prima_terr     = 0;
		if _opcion = 0 then
			FOREACH
			  Select reacobre.es_terremoto,
					 SUM(emireau2.prima_neta_o)
				into _es_terremoto,
					 _prima_neta
				From emireau2, prdcober, reacobre
			   Where emireau2.no_poliza = v_poliza
				 And emireau2.no_unidad = _no_unidad
				 And emireau2.cod_cobertura = prdcober.cod_cobertura
				 and emireau2.chek_o    = 1
				 And prdcober.cod_cober_reas = reacobre.cod_cober_reas
			   Group by reacobre.es_terremoto
			   
				if _es_terremoto = 0 then
					let _prima_incendio = _prima_incendio + _prima_neta;
				else
					let _prima_terr = _prima_terr + _prima_neta;
				end if	
			  
			END FOREACH
		elif _opcion = 1 then
			FOREACH
			  Select reacobre.es_terremoto,
					 SUM(emireau2.prima_neta_1)
				into _es_terremoto,
					 _prima_neta
				From emireau2, prdcober, reacobre
			   Where emireau2.no_poliza = v_poliza
				 And emireau2.no_unidad = _no_unidad
				 And emireau2.cod_cobertura = prdcober.cod_cobertura
				 and emireau2.chek_1    = 1
				 And prdcober.cod_cober_reas = reacobre.cod_cober_reas
			   Group by reacobre.es_terremoto
			   
				if _es_terremoto = 0 then
					let _prima_incendio = _prima_incendio + _prima_neta;
				else
					let _prima_terr = _prima_terr + _prima_neta;
				end if	
			  
			END FOREACH
		elif _opcion = 2 then
			FOREACH
			  Select reacobre.es_terremoto,
					 SUM(emireau2.prima_neta_2)
				into _es_terremoto,
					 _prima_neta
				From emireau2, prdcober, reacobre
			   Where emireau2.no_poliza = v_poliza
				 And emireau2.no_unidad = _no_unidad
				 And emireau2.cod_cobertura = prdcober.cod_cobertura
				 and emireau2.chek_2    = 1
				 And prdcober.cod_cober_reas = reacobre.cod_cober_reas
			   Group by reacobre.es_terremoto
			   
				if _es_terremoto = 0 then
					let _prima_incendio = _prima_incendio + _prima_neta;
				else
					let _prima_terr = _prima_terr + _prima_neta;
				end if	
			  
			END FOREACH
		end if
	    update emirecum
		   set prima_incendio  = _prima_incendio,
			   prima_terremoto = _prima_terr
		 where no_poliza       = v_poliza
		   and no_unidad       = _no_unidad;		
	end foreach	
	end if
end if

if a_flag = 10 then	--Procedimiento que Retorna la Depreciacion por Unidad de la poliza
	CALL sp_pro82o(v_poliza) RETURNING _porc_depre;	
	update emirepol
	   set porc_depreciacion = _porc_depre
	 where no_poliza = v_poliza;	 
end if


end
--commit work;
end procedure;

