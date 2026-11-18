# JSON-LD Schema Templates

## 1. FAQPage Schema (+40% AI Visibility)

```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is [Product/Service]?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "[Comprehensive answer with statistics and citations.]"
      }
    },
    {
      "@type": "Question",
      "name": "How does [Product/Service] work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "[Step-by-step explanation. First... Then... Finally...]"
      }
    },
    {
      "@type": "Question",
      "name": "How much does [Product/Service] cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "[Pricing information. Plans start at $X/month.]"
      }
    }
  ]
}
```

## 2. Article Schema

```json
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "[Article Title - Max 110 characters]",
  "description": "[Article summary]",
  "image": ["https://example.com/image-16x9.jpg"],
  "datePublished": "2024-01-15T08:00:00+00:00",
  "dateModified": "2024-12-20T10:30:00+00:00",
  "author": {
    "@type": "Person",
    "name": "[Author Name]",
    "url": "https://example.com/author/name"
  },
  "publisher": {
    "@type": "Organization",
    "name": "[Publisher Name]",
    "logo": {
      "@type": "ImageObject",
      "url": "https://example.com/logo.png",
      "width": 600,
      "height": 60
    }
  },
  "mainEntityOfPage": {
    "@type": "WebPage",
    "@id": "https://example.com/article-url"
  },
  "keywords": ["keyword1", "keyword2"],
  "speakable": {
    "@type": "SpeakableSpecification",
    "cssSelector": ["h1", ".summary", ".key-points"]
  }
}
```

## 3. SoftwareApplication Schema

```json
{
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  "name": "[App Name]",
  "applicationCategory": "DeveloperApplication",
  "operatingSystem": "Cross-platform",
  "url": "https://example.com",
  "softwareVersion": "1.0.0",
  "featureList": ["Feature 1", "Feature 2", "Feature 3"],
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  },
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.8",
    "ratingCount": "150"
  }
}
```

## 4. Organization Schema

```json
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "[Organization Name]",
  "url": "https://example.com",
  "logo": "https://example.com/logo.png",
  "description": "[Organization description]",
  "foundingDate": "2024",
  "sameAs": [
    "https://twitter.com/example",
    "https://github.com/example",
    "https://linkedin.com/company/example"
  ]
}
```

## 5. Product Schema

```json
{
  "@context": "https://schema.org",
  "@type": "Product",
  "name": "[Product Name]",
  "description": "[Product description]",
  "image": ["https://example.com/product-image-1.jpg"],
  "brand": { "@type": "Brand", "name": "[Brand Name]" },
  "offers": {
    "@type": "Offer",
    "priceCurrency": "USD",
    "price": "99.99",
    "availability": "https://schema.org/InStock"
  },
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.5",
    "reviewCount": "89"
  }
}
```

## 6. HowTo Schema

```json
{
  "@context": "https://schema.org",
  "@type": "HowTo",
  "name": "How to [Do Something]",
  "description": "[Brief description]",
  "totalTime": "PT15M",
  "step": [
    {
      "@type": "HowToStep",
      "name": "Step 1: [Step Name]",
      "text": "[Detailed step instructions]"
    },
    {
      "@type": "HowToStep",
      "name": "Step 2: [Step Name]",
      "text": "[Detailed step instructions]"
    }
  ]
}
```

## 7. LocalBusiness Schema

```json
{
  "@context": "https://schema.org",
  "@type": "LocalBusiness",
  "name": "[Business Name]",
  "url": "https://example.com",
  "telephone": "+1-555-555-5555",
  "address": {
    "@type": "PostalAddress",
    "streetAddress": "[Street]",
    "addressLocality": "[City]",
    "addressRegion": "[State]",
    "postalCode": "[ZIP]",
    "addressCountry": "US"
  },
  "geo": {
    "@type": "GeoCoordinates",
    "latitude": 37.7749,
    "longitude": -122.4194
  },
  "openingHoursSpecification": [
    {
      "@type": "OpeningHoursSpecification",
      "dayOfWeek": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"],
      "opens": "09:00",
      "closes": "17:00"
    }
  ]
}
```

## 8. BreadcrumbList Schema

```json
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    { "@type": "ListItem", "position": 1, "name": "Home", "item": "https://example.com" },
    { "@type": "ListItem", "position": 2, "name": "[Category]", "item": "https://example.com/category" },
    { "@type": "ListItem", "position": 3, "name": "[Current Page]", "item": "https://example.com/category/page" }
  ]
}
```

## 9. Combined Schema (Multi-type page)

Use `@graph` for pages with multiple schema types:

```json
{
  "@context": "https://schema.org",
  "@graph": [
    { "@type": "WebPage", "name": "...", "speakable": { "cssSelector": ["h1"] } },
    { "@type": "SoftwareApplication", "name": "..." },
    { "@type": "FAQPage", "mainEntity": [...] },
    { "@type": "Organization", "name": "...", "sameAs": [...] }
  ]
}
```

## Validation

- **Google Rich Results Test**: `https://search.google.com/test/rich-results?url={your-url}`
- **Schema.org Validator**: `https://validator.schema.org/?url={your-url}`