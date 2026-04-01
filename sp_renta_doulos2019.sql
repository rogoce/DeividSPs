

drop procedure sp_renta_doulos2019;
create procedure sp_renta_doulos2019()
returning char(3),char(20),char(5),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),varchar(50),varchar(50);

define _n_tipo,_tipo	char(3);

define _no_documento		char(20);
define _cod_agente	char(5);
define _sin_pen_aa,_sin_pen_ap,_sin_pag_aa,_pri_sus_aa,_pri_sus_ap,_pncd dec(16,2);
define _n_corr,_n_cliente varchar(50);


begin
foreach
	select f.cod_agente,a.nombre,f.no_documento,sum(f.sin_pen_aa),sum(f.sin_pen_ap),sum(f.sin_pag_aa),sum(f.pri_sus_pag),sum(f.pri_sus_pag_ap),sum(f.pri_pag)
	  into _cod_agente,_n_corr,_no_documento,_sin_pen_aa,_sin_pen_ap,_sin_pag_aa,_pri_sus_aa,_pri_sus_ap,_pncd
	  from fis_che115a f, agtagent a
	 where f.cod_agente = a.cod_agente
	   and f.cod_agente in('00623','01048','01315','01569','01575','01834','01835', '01836', '01837', '02201', '02252','02253', '02349','02393', '02448', '02599')
	   --and f.no_documento = '0207-01420-01'
	   and f.no_documento in(
	select no_documento from rentabilidad1
	 where cod_agente = '01048')
	 group by f.cod_agente,a.nombre,f.no_documento
	 order by f.no_documento,f.cod_agente
	 
	foreach
      select n_cliente,tipo
        into _n_cliente,_tipo
        from rentabilidad1
       where no_documento = _no_documento
    exit foreach;
    end foreach

	if _tipo = '001' then
	  let _n_tipo = 'AUT';
	elif _tipo = '003' then
	  let _n_tipo = 'PAT';
	else
	let _n_tipo = 'COL';
    end if	
	
	return _n_tipo,_no_documento,_cod_agente,_sin_pen_aa,_sin_pen_ap,_sin_pag_aa,_pri_sus_aa,_pri_sus_ap,_pncd,_n_corr,_n_cliente with resume;
	
end foreach	

end

end procedure
