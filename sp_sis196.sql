-- Seleccion del Contrato de Retencion
-- 
-- Creado    : 07/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 07/08/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 31/07/2015 - Armando, las polizas coaseguro minoritario no deben ir al pool de impresion, correo de arlink 31/07/2015
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis196;
create procedure "informix".sp_sis196(a_no_poliza char(10))
returning smallint;

define _cod_ramo	char(3);
define _cnt 		smallint;
define _cnnt        integer;
define _cod_tipoprod char(3);

select cod_ramo,
       cod_tipoprod
  into _cod_ramo,
       _cod_tipoprod
  from emipomae
 where no_poliza = a_no_poliza;

let _cnt = 0;

if _cod_ramo <> '008' then
	select count(*)
	  into _cnt
	  from agtagent a, emipoagt e
	 where a.cod_agente  = e.cod_agente
	   and e.no_poliza   = a_no_poliza
	   and a.tipo_agente = 'O';
	   
	if _cnt is null then
		let _cnt = 0;
	end if

    if _cnt > 0 then   --tiene corredor oficina
		select count(*)
		  into _cnnt
	      from emipoacr
	     where no_poliza = a_no_poliza; --se busca si tiene acreedor, y si tiene debe ir al pool de impresion
	 
		if _cnnt is null then
			let _cnnt = 0;
		end if	
	 
		if _cnnt = 0 then	--no tiene acreedor
		else
			let _cnt = 0;
		end if
    end if
    if _cod_tipoprod = '002' then --coaseguro minoritario no debe ir al pool de impresion
		let _cnt = 1;	
	end if
end if

return _cnt;

end procedure; 