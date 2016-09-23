# -*- encoding : utf-8 -*-
require 'spec_helper'

describe BlacklightSolrplugins::FacetFieldWindow do

  context 'via target to full window of results' do
    it 'should work' do
      facet_field = double("FacetField")
      allow(facet_field).to receive(:items).and_return(('a'..'g').to_a)
      allow(facet_field).to receive(:target_offset).and_return(1)

      facet_field_window = BlacklightSolrplugins::FacetFieldWindow.new(facet_field, 5, 1)

      expect(facet_field_window.has_previous).to eq(true)
      expect(facet_field_window.has_next).to eq(true)
      expect(facet_field_window.items).to eq(('b'..'f').to_a)
    end
  end

  context 'via target to non-full window of results' do
    it 'should work' do
      facet_field = double("FacetField")
      allow(facet_field).to receive(:items).and_return(('a'..'d').to_a)
      allow(facet_field).to receive(:target_offset).and_return(1)

      facet_field_window = BlacklightSolrplugins::FacetFieldWindow.new(facet_field, 5, 1)

      expect(facet_field_window.has_previous).to eq(true)
      expect(facet_field_window.has_next).to eq(false)
      expect(facet_field_window.items).to eq(('b'..'d').to_a)
    end
  end

  context 'via back button to a full window of results' do
    it 'should work' do
      facet_field = double("FacetField")
      allow(facet_field).to receive(:items).and_return(('a'..'g').to_a)
      allow(facet_field).to receive(:target_offset).and_return(6)

      facet_field_window = BlacklightSolrplugins::FacetFieldWindow.new(facet_field, 5, 6)

      expect(facet_field_window.has_previous).to eq(true)
      expect(facet_field_window.has_next).to eq(true)
      expect(facet_field_window.items).to eq(('b'..'f').to_a)
    end
  end

  context 'via next button to a full window of results' do
    it 'should work' do
      facet_field = double("FacetField")
      allow(facet_field).to receive(:items).and_return(('a'..'g').to_a)
      allow(facet_field).to receive(:target_offset).and_return(0)

      facet_field_window = BlacklightSolrplugins::FacetFieldWindow.new(facet_field, 5, 0)

      expect(facet_field_window.has_previous).to eq(true)
      expect(facet_field_window.has_next).to eq(true)
      expect(facet_field_window.items).to eq(('b'..'f').to_a)
    end
  end

  context 'via back button to exact start of results' do
    it 'should work' do
      facet_field = double("FacetField")
      allow(facet_field).to receive(:items).and_return(('a'..'g').to_a)
      allow(facet_field).to receive(:target_offset).and_return(4)

      facet_field_window = BlacklightSolrplugins::FacetFieldWindow.new(facet_field, 5, 6)

      expect(facet_field_window.has_previous).to eq(false)
      expect(facet_field_window.has_next).to eq(true)
      expect(facet_field_window.items).to eq(('a'..'e').to_a)
    end
  end

  context 'via next button to exact end of results' do
    it 'should work' do
      facet_field = double("FacetField")
      allow(facet_field).to receive(:items).and_return(('a'..'g').to_a)
      allow(facet_field).to receive(:target_offset).and_return(2)

      facet_field_window = BlacklightSolrplugins::FacetFieldWindow.new(facet_field, 5, 0)

      expect(facet_field_window.has_previous).to eq(true)
      expect(facet_field_window.has_next).to eq(false)
      expect(facet_field_window.items).to eq(('c'..'g').to_a)
    end
  end

  context 'via back button to start of results that is smaller than window, where target_offset falls short' do
    it 'should work' do
      facet_field = double("FacetField")
      allow(facet_field).to receive(:items).and_return(('a'..'d').to_a)
      allow(facet_field).to receive(:target_offset).and_return(3)

      facet_field_window = BlacklightSolrplugins::FacetFieldWindow.new(facet_field, 5, 6)

      expect(facet_field_window.has_previous).to eq(false)
      expect(facet_field_window.has_next).to eq(false)
      expect(facet_field_window.items).to eq(('a'..'d').to_a)
    end
  end

  context 'via next button to end of results that is smaller than window, where target_offset falls short' do
    it 'should work' do
      facet_field = double("FacetField")
      allow(facet_field).to receive(:items).and_return(('a'..'d').to_a)
      allow(facet_field).to receive(:target_offset).and_return(0)

      facet_field_window = BlacklightSolrplugins::FacetFieldWindow.new(facet_field, 5, 0)

      expect(facet_field_window.has_previous).to eq(false)
      expect(facet_field_window.has_next).to eq(false)
      expect(facet_field_window.items).to eq(('a'..'d').to_a)
    end
  end

  context 'via prev button to start of results that is a full window, where target_offset falls in middle' do
    it 'should work' do
      facet_field = double("FacetField")
      allow(facet_field).to receive(:items).and_return(('a'..'g').to_a)
      allow(facet_field).to receive(:target_offset).and_return(4)

      facet_field_window = BlacklightSolrplugins::FacetFieldWindow.new(facet_field, 5, 6)

      expect(facet_field_window.has_previous).to eq(false)
      expect(facet_field_window.has_next).to eq(true)
      expect(facet_field_window.items).to eq(('a'..'e').to_a)
    end
  end

  context 'via next button to end of results that is a full window, where target_offset falls in middle' do
    it 'should work' do
      facet_field = double("FacetField")
      allow(facet_field).to receive(:items).and_return(('a'..'g').to_a)
      allow(facet_field).to receive(:target_offset).and_return(4)

      facet_field_window = BlacklightSolrplugins::FacetFieldWindow.new(facet_field, 5, 0)

      expect(facet_field_window.has_previous).to eq(true)
      expect(facet_field_window.has_next).to eq(false)
      expect(facet_field_window.items).to eq(('c'..'g').to_a)
    end
  end

end
